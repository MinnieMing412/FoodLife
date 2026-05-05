#!/usr/bin/env bash
set -euo pipefail

EPICS_FILE="${EPICS_FILE:-_bmad-output/planning-artifacts/epics.md}"
SPRINT_STATUS_FILE="${SPRINT_STATUS_FILE:-_bmad-output/implementation-artifacts/sprint-status.yaml}"
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

if [[ ! -f "$SPRINT_STATUS_FILE" ]]; then
  echo "Sprint status file not found: $SPRINT_STATUS_FILE"
  exit 1
fi

PROJECT_NUMBER="$(gh project list --owner "$OWNER" --format json --jq ".projects[] | select(.title == \"$PROJECT_TITLE\") | .number" | head -n 1)"
if [[ -z "$PROJECT_NUMBER" ]]; then
  echo "GitHub Project not found: $PROJECT_TITLE"
  echo "Run: scripts/github/create-sprint-project.sh"
  exit 1
fi

PROJECT_ID="$(gh project view "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.id')"
STATUS_FIELD_ID="$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --jq '.fields[] | select(.name == "Status") | .id')"

if [[ -z "$PROJECT_ID" || -z "$STATUS_FIELD_ID" ]]; then
  echo "Could not resolve GitHub Project ID or Status field ID."
  exit 1
fi

option_id_for_status() {
  local project_status="$1"
  gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json \
    --jq ".fields[] | select(.name == \"Status\") | .options[] | select(.name == \"$project_status\") | .id"
}

TODO_OPTION_ID="$(option_id_for_status "Todo")"
IN_PROGRESS_OPTION_ID="$(option_id_for_status "In Progress")"
DONE_OPTION_ID="$(option_id_for_status "Done")"

if [[ -z "$TODO_OPTION_ID" || -z "$IN_PROGRESS_OPTION_ID" || -z "$DONE_OPTION_ID" ]]; then
  echo "Could not resolve one or more GitHub Project Status options."
  exit 1
fi

for status in backlog ready in-progress review done; do
  gh label create "status:$status" --repo "$OWNER/$REPO" --color "C5DEF5" --description "BMad status: $status" --force >/dev/null
done

tmp_items="$(mktemp)"
tmp_issues="$(mktemp)"
tmp_project_items="$(mktemp)"
tmp_rest_issues="$(mktemp)"
tmp_sub_issue_links="$(mktemp)"
tmp_existing_sub_issues="$(mktemp)"
trap 'rm -f "$tmp_items" "$tmp_issues" "$tmp_project_items" "$tmp_rest_issues" "$tmp_sub_issue_links" "$tmp_existing_sub_issues"' EXIT

python3 - "$EPICS_FILE" "$SPRINT_STATUS_FILE" > "$tmp_items" <<'PY'
import re
import sys
from pathlib import Path

epics_path = Path(sys.argv[1])
status_path = Path(sys.argv[2])

epics_text = epics_path.read_text(encoding="utf-8")
status_text = status_path.read_text(encoding="utf-8")

epic_titles = {}
story_titles = {}

def slugify(title: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-") or "untitled"

for line in epics_text.splitlines():
    epic_match = re.match(r"^## Epic (\d+):\s*(.+?)\s*$", line)
    if epic_match:
        epic_titles[epic_match.group(1)] = epic_match.group(2)
        continue

    story_match = re.match(r"^### Story (\d+)\.(\d+):\s*(.+?)\s*$", line)
    if story_match:
        epic_num, story_num, title = story_match.groups()
        key = f"{epic_num}-{story_num}-{slugify(title)}"
        story_titles[key] = (f"{epic_num}.{story_num}", title)

in_development_status = False
for raw_line in status_text.splitlines():
    if raw_line.strip() == "development_status:":
        in_development_status = True
        continue
    if not in_development_status:
        continue
    if raw_line and not raw_line.startswith("  "):
        break

    match = re.match(r"^\s{2}([^:#]+):\s*(\S+)\s*$", raw_line)
    if not match:
        continue

    key, bmad_status = match.groups()
    if key.endswith("-retrospective"):
        continue

    if key.startswith("epic-"):
        epic_num = key.split("-", 1)[1]
        title = epic_titles.get(epic_num)
        if not title:
            continue
        issue_title = f"Epic {epic_num}: {title}"
    else:
        story = story_titles.get(key)
        if not story:
            continue
        story_id, title = story
        issue_title = f"Story {story_id}: {title}"

    if bmad_status in {"backlog", "ready-for-dev"}:
        project_status = "Todo"
    elif bmad_status in {"in-progress", "review"}:
        project_status = "In Progress"
    elif bmad_status == "done":
        project_status = "Done"
    else:
        continue

    github_label = "status:ready" if bmad_status == "ready-for-dev" else f"status:{bmad_status}"
    print("\t".join([issue_title, bmad_status, github_label, project_status]))
PY

project_option_id() {
  case "$1" in
    Todo) echo "$TODO_OPTION_ID" ;;
    "In Progress") echo "$IN_PROGRESS_OPTION_ID" ;;
    Done) echo "$DONE_OPTION_ID" ;;
    *) return 1 ;;
  esac
}

echo "Syncing GitHub issue labels and project statuses for $OWNER/$REPO..."

gh issue list --repo "$OWNER/$REPO" --state all --limit 500 --json number,title,labels > "$tmp_issues"
gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --limit 500 > "$tmp_project_items"

tmp_sync_plan="$(mktemp)"
trap 'rm -f "$tmp_items" "$tmp_issues" "$tmp_project_items" "$tmp_rest_issues" "$tmp_sub_issue_links" "$tmp_existing_sub_issues" "$tmp_sync_plan"' EXIT

python3 - "$tmp_items" "$tmp_issues" "$tmp_project_items" > "$tmp_sync_plan" <<'PY'
import json
import sys
from pathlib import Path

items_path, issues_path, project_items_path = map(Path, sys.argv[1:])

issues = json.loads(issues_path.read_text(encoding="utf-8"))
project_items = json.loads(project_items_path.read_text(encoding="utf-8")).get("items", [])

issues_by_title = {issue["title"]: issue for issue in issues}
items_by_issue_number = {
    item.get("content", {}).get("number"): item
    for item in project_items
    if item.get("content", {}).get("type") == "Issue"
}

for raw in items_path.read_text(encoding="utf-8").splitlines():
    issue_title, bmad_status, github_label, project_status = raw.split("\t")
    issue = issues_by_title.get(issue_title)
    if not issue:
        print("\t".join(["missing", issue_title, bmad_status, github_label, project_status, "", "", "", ""]))
        continue

    issue_number = str(issue["number"])
    labels = [label["name"] for label in issue.get("labels", [])]
    current_status_labels = [label for label in labels if label.startswith("status:")]
    label_needs_update = current_status_labels != [github_label]

    item = items_by_issue_number.get(issue["number"]) or {}
    item_id = item.get("id", "")
    current_project_status = item.get("status", "")
    project_needs_update = bool(item_id) and current_project_status != project_status
    needs_add_to_project = not item_id

    print(
        "\t".join(
            [
                "ok",
                issue_title,
                bmad_status,
                github_label,
                project_status,
                issue_number,
                item_id,
                "1" if label_needs_update else "0",
                "1" if project_needs_update else "0",
                "1" if needs_add_to_project else "0",
            ]
        )
    )
PY

while IFS=$'\t' read -r row_state issue_title bmad_status github_label project_status issue_number item_id label_needs_update project_needs_update needs_add_to_project; do
  if [[ "$row_state" == "missing" ]]; then
    echo "Issue not found, skipping: $issue_title"
    continue
  fi

  if [[ "$label_needs_update" == "1" ]]; then
    gh issue edit "$issue_number" --repo "$OWNER/$REPO" \
      --remove-label "status:backlog,status:ready,status:in-progress,status:review,status:done" >/dev/null 2>&1 || true
    gh issue edit "$issue_number" --repo "$OWNER/$REPO" --add-label "$github_label" >/dev/null
  fi

  if [[ "$needs_add_to_project" == "1" ]]; then
    issue_url="$(gh issue view "$issue_number" --repo "$OWNER/$REPO" --json url --jq '.url')"
    gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$issue_url" >/dev/null || true
    item_id="$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json --limit 500 \
      --jq ".items[] | select(.content.number == $issue_number) | .id" | head -n 1)"
    project_needs_update="1"
  fi

  if [[ -n "$item_id" && "$project_needs_update" == "1" ]]; then
    option_id="$(project_option_id "$project_status")"
    gh project item-edit \
      --id "$item_id" \
      --project-id "$PROJECT_ID" \
      --field-id "$STATUS_FIELD_ID" \
      --single-select-option-id "$option_id" >/dev/null
  fi

  echo "$issue_title: $bmad_status -> $project_status"
done < "$tmp_sync_plan"

echo "Ensuring story issues are sub-issues of their epics..."
gh api "repos/$OWNER/$REPO/issues?state=all&per_page=100" --paginate > "$tmp_rest_issues"

python3 - "$EPICS_FILE" "$tmp_rest_issues" > "$tmp_sub_issue_links" <<'PY'
import json
import re
import sys
from pathlib import Path

epics_path = Path(sys.argv[1])
issues_path = Path(sys.argv[2])

issues = json.loads(issues_path.read_text(encoding="utf-8"))
issues_by_title = {issue["title"]: issue for issue in issues}
epic_titles = {}

for line in epics_path.read_text(encoding="utf-8").splitlines():
    epic_match = re.match(r"^## Epic (\d+):\s*(.+?)\s*$", line)
    if epic_match:
        epic_titles[epic_match.group(1)] = epic_match.group(2)
        continue

    story_match = re.match(r"^### Story (\d+)\.(\d+):\s*(.+?)\s*$", line)
    if not story_match:
        continue

    epic_num, story_num, story_title = story_match.groups()
    epic_title = epic_titles.get(epic_num)
    if not epic_title:
        continue

    parent_issue = issues_by_title.get(f"Epic {epic_num}: {epic_title}")
    story_issue = issues_by_title.get(f"Story {epic_num}.{story_num}: {story_title}")
    if not parent_issue or not story_issue:
        continue

    print("\t".join([str(parent_issue["number"]), str(story_issue["id"]), f"Story {epic_num}.{story_num}: {story_title}"]))
PY

cut -f1 "$tmp_sub_issue_links" | sort -u | while read -r parent_issue_number; do
  [[ -n "$parent_issue_number" ]] || continue
  gh api \
    -H "X-GitHub-Api-Version: 2026-03-10" \
    "repos/$OWNER/$REPO/issues/$parent_issue_number/sub_issues?per_page=100" \
    --jq ".[] | \"$parent_issue_number\t\\(.id)\"" >> "$tmp_existing_sub_issues" || true
done

while IFS=$'\t' read -r parent_issue_number sub_issue_database_id story_title; do
  if grep -Fqx "$parent_issue_number	$sub_issue_database_id" "$tmp_existing_sub_issues" 2>/dev/null; then
    echo "Sub-issue already linked: $story_title"
    continue
  fi

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
