#!/usr/bin/env bash
set -euo pipefail

EPICS_FILE="${EPICS_FILE:-_bmad-output/planning-artifacts/epics.md}"
PROJECT_TITLE="${PROJECT_TITLE:-FoodLife Sprint Tracking}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed. Install GitHub CLI first: https://cli.github.com/"
  exit 1
fi

gh auth status >/dev/null

REPOSITORY="${GITHUB_REPOSITORY:-}"
if [[ -z "$REPOSITORY" ]]; then
  REPOSITORY="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
fi

OWNER="${GITHUB_OWNER:-${REPOSITORY%%/*}}"
REPO="${GITHUB_REPO:-${REPOSITORY#*/}}"

if [[ ! -f "$EPICS_FILE" ]]; then
  echo "Epics file not found: $EPICS_FILE"
  exit 1
fi

if ! gh project list --owner "$OWNER" --format json --limit 1 >/dev/null 2>&1; then
  echo "GitHub Projects access is unavailable."
  echo "Run: gh auth refresh -s read:project -s project"
  exit 1
fi

tmp_items="$(mktemp)"
tmp_rest_issues="$(mktemp)"
tmp_sub_issue_links="$(mktemp)"
trap 'rm -f "$tmp_items" "$tmp_rest_issues" "$tmp_sub_issue_links"' EXIT

python3 - "$EPICS_FILE" > "$tmp_items" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
lines = text.splitlines()

epics = []
current = None

def slugify(title: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
    return slug or "untitled"

for i, line in enumerate(lines):
    epic_match = re.match(r"^## Epic (\d+):\s*(.+?)\s*$", line)
    if epic_match:
        current = {
            "num": epic_match.group(1),
            "title": epic_match.group(2),
            "summary": "",
            "stories": [],
        }
        epics.append(current)

        for later in lines[i + 1:]:
            stripped = later.strip()
            if not stripped:
                continue
            if stripped.startswith("#"):
                break
            current["summary"] = stripped
            break
        continue

    story_match = re.match(r"^### Story (\d+)\.(\d+):\s*(.+?)\s*$", line)
    if story_match and current:
        epic_num, story_num, title = story_match.groups()
        key = f"{epic_num}-{story_num}-{slugify(title)}"
        current["stories"].append(
            {
                "id": f"{epic_num}.{story_num}",
                "epic": epic_num,
                "title": title,
                "key": key,
            }
        )

if not epics:
    raise SystemExit("No epics found. Expected headings like '## Epic 1: Title'.")

for epic in epics:
    print("\t".join(["E", epic["num"], epic["title"], epic["summary"]]))
    for story in epic["stories"]:
        print("\t".join(["S", story["epic"], story["id"], story["title"], story["key"]]))
PY

echo "Creating labels in $OWNER/$REPO..."
gh label create "type: epic" --repo "$OWNER/$REPO" --color "5319E7" --description "Epic-level planning issue" --force
gh label create "type: story" --repo "$OWNER/$REPO" --color "1D76DB" --description "Implementable user story" --force
gh label create "status: backlog" --repo "$OWNER/$REPO" --color "C5DEF5" --description "Not started" --force
gh label create "status: ready" --repo "$OWNER/$REPO" --color "0E8A16" --description "Ready for development" --force
gh label create "status: in-progress" --repo "$OWNER/$REPO" --color "FBCA04" --description "Actively being worked" --force
gh label create "status: review" --repo "$OWNER/$REPO" --color "D93F0B" --description "Ready for review" --force
gh label create "status: done" --repo "$OWNER/$REPO" --color "0E8A16" --description "Complete" --force

while IFS=$'\t' read -r kind epic_num _rest; do
  [[ "$kind" == "E" ]] || continue
  gh label create "epic:$epic_num" --repo "$OWNER/$REPO" --color "BFDADC" --description "Epic $epic_num" --force
done < "$tmp_items"

create_milestone() {
  local title="$1"
  local description="$2"
  if gh api "repos/$OWNER/$REPO/milestones" --paginate --jq '.[].title' | grep -Fxq "$title"; then
    echo "Milestone exists: $title"
  else
    gh api "repos/$OWNER/$REPO/milestones" \
      -f title="$title" \
      -f description="$description" >/dev/null
  fi
}

echo "Creating sprint milestones..."
while IFS=$'\t' read -r kind epic_num epic_title epic_summary; do
  [[ "$kind" == "E" ]] || continue
  create_milestone "Sprint $epic_num - $epic_title" "Epic $epic_num: $epic_summary"
done < "$tmp_items"

echo "Creating GitHub Project..."
PROJECT_NUMBER="$(gh project list --owner "$OWNER" --format json --jq ".projects[] | select(.title == \"$PROJECT_TITLE\") | .number" | head -n 1)"
if [[ -z "$PROJECT_NUMBER" ]]; then
  PROJECT_NUMBER="$(gh project create --owner "$OWNER" --title "$PROJECT_TITLE" --format json --jq '.number')"
fi
echo "Project number: $PROJECT_NUMBER"

add_to_project() {
  local url="$1"
  gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$url" >/dev/null || true
}

create_issue() {
  local title="$1"
  local body="$2"
  local milestone="$3"
  shift 3
  local labels=("$@")

  local existing_url
  existing_url="$(gh issue list --repo "$OWNER/$REPO" --state all --search "$title in:title" --json title,url --jq ".[] | select(.title == \"$title\") | .url" | head -n 1)"
  if [[ -n "$existing_url" ]]; then
    echo "Issue exists: $title"
    add_to_project "$existing_url"
    return
  fi

  local label_arg
  label_arg="$(IFS=,; echo "${labels[*]}")"
  local url
  url="$(gh issue create \
    --repo "$OWNER/$REPO" \
    --title "$title" \
    --body "$body" \
    --milestone "$milestone" \
    --label "$label_arg")"
  add_to_project "$url"
}

echo "Creating epic issues..."
while IFS=$'\t' read -r kind epic_num epic_title epic_summary; do
  [[ "$kind" == "E" ]] || continue
  create_issue \
    "Epic $epic_num: $epic_title" \
    "Source: \`$EPICS_FILE\`

$epic_summary

Use child story issues and the sprint milestone to track implementation progress." \
    "Sprint $epic_num - $epic_title" \
    "type: epic" "epic:$epic_num" "status: backlog"
done < "$tmp_items"

echo "Creating story issues..."
while IFS=$'\t' read -r kind epic_num story_id story_title story_key; do
  [[ "$kind" == "S" ]] || continue
  epic_title="$(awk -F '\t' -v epic="$epic_num" '$1 == "E" && $2 == epic { print $3; exit }' "$tmp_items")"
  create_issue \
    "Story $story_id: $story_title" \
    "Source: \`$EPICS_FILE\`

Tracking key: \`$story_key\`
Epic: $epic_num
Initial status: backlog

Use this issue as the implementation tracking item for Story $story_id." \
    "Sprint $epic_num - $epic_title" \
    "type: story" "epic:$epic_num" "status: backlog"
done < "$tmp_items"

echo "Linking story issues as sub-issues of their epics..."
gh api "repos/$OWNER/$REPO/issues?state=all&per_page=100" --paginate > "$tmp_rest_issues"

python3 - "$tmp_items" "$tmp_rest_issues" > "$tmp_sub_issue_links" <<'PY'
import json
import sys
from pathlib import Path

items_path = Path(sys.argv[1])
issues_path = Path(sys.argv[2])

issues = json.loads(issues_path.read_text(encoding="utf-8"))
issues_by_title = {issue["title"]: issue for issue in issues}
epic_issue_numbers = {}

for raw in items_path.read_text(encoding="utf-8").splitlines():
    parts = raw.split("\t")
    if parts[0] == "E":
        _, epic_num, epic_title, _summary = parts
        issue = issues_by_title.get(f"Epic {epic_num}: {epic_title}")
        if issue:
            epic_issue_numbers[epic_num] = issue["number"]

for raw in items_path.read_text(encoding="utf-8").splitlines():
    parts = raw.split("\t")
    if parts[0] != "S":
        continue
    _, epic_num, story_id, story_title, _story_key = parts
    parent_number = epic_issue_numbers.get(epic_num)
    story_issue = issues_by_title.get(f"Story {story_id}: {story_title}")
    if not parent_number or not story_issue:
        continue
    print("\t".join([str(parent_number), str(story_issue["id"]), f"Story {story_id}: {story_title}"]))
PY

while IFS=$'\t' read -r parent_issue_number sub_issue_database_id story_title; do
  if gh api \
    -X POST \
    -H "X-GitHub-Api-Version: 2026-03-10" \
    "repos/$OWNER/$REPO/issues/$parent_issue_number/sub_issues" \
    -F "sub_issue_id=$sub_issue_database_id" \
    -F "replace_parent=true" >/dev/null 2>&1; then
    echo "Linked sub-issue: $story_title"
  else
    echo "Sub-issue link already exists or could not be updated: $story_title"
  fi
done < "$tmp_sub_issue_links"

echo "Done."
echo "Open: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
