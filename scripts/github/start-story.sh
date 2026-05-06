#!/usr/bin/env bash
set -euo pipefail

STORY_FILE="${1:-${STORY_FILE:-}}"
SPRINT_STATUS_FILE="${SPRINT_STATUS_FILE:-_bmad-output/implementation-artifacts/sprint-status.yaml}"
PROJECT_TITLE="${PROJECT_TITLE:-FoodLife Sprint Tracking}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed. Install GitHub CLI first: https://cli.github.com/"
  exit 1
fi

if [[ -z "$STORY_FILE" ]]; then
  if [[ ! -f "$SPRINT_STATUS_FILE" ]]; then
    echo "Story file was not provided and sprint status file was not found: $SPRINT_STATUS_FILE"
    exit 1
  fi

  story_key="$(
    awk '
      $0 == "development_status:" { in_status = 1; next }
      in_status && $0 !~ /^  / { exit }
      in_status && $2 == "in-progress" && $1 !~ /^epic-/ && $1 !~ /-retrospective:$/ {
        key = $1
        sub(/:$/, "", key)
        print key
        exit
      }
    ' "$SPRINT_STATUS_FILE"
  )"

  if [[ -z "$story_key" ]]; then
    story_key="$(
      awk '
        $0 == "development_status:" { in_status = 1; next }
        in_status && $0 !~ /^  / { exit }
        in_status && $2 == "ready-for-dev" && $1 !~ /^epic-/ && $1 !~ /-retrospective:$/ {
          key = $1
          sub(/:$/, "", key)
          print key
          exit
        }
      ' "$SPRINT_STATUS_FILE"
    )"
  fi

  if [[ -z "$story_key" ]]; then
    echo "No in-progress or ready-for-dev story found in $SPRINT_STATUS_FILE"
    exit 1
  fi

  STORY_FILE="_bmad-output/implementation-artifacts/${story_key}.md"
fi

if [[ ! -f "$STORY_FILE" ]]; then
  echo "Story file not found: $STORY_FILE"
  exit 1
fi

REPOSITORY="${GITHUB_REPOSITORY:-}"
if [[ -z "$REPOSITORY" ]]; then
  REPOSITORY="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
fi

OWNER="${GITHUB_OWNER:-${REPOSITORY%%/*}}"
REPO="${GITHUB_REPO:-${REPOSITORY#*/}}"
REPO_FULL_NAME="$OWNER/$REPO"

if ! gh issue list --repo "$REPO_FULL_NAME" --limit 1 >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated for repository issue access."
  echo "Run: gh auth login"
  exit 1
fi

tmp_body="$(mktemp)"
trap 'rm -f "$tmp_body"' EXIT

story_meta="$(
  python3 - "$STORY_FILE" "$tmp_body" <<'PY'
import re
import sys
from pathlib import Path

story_path = Path(sys.argv[1])
body_path = Path(sys.argv[2])
text = story_path.read_text(encoding="utf-8")
lines = text.splitlines()

title_line = next((line for line in lines if line.startswith("# Story ")), "")
match = re.match(r"^# Story (\d+)\.(\d+):\s*(.+?)\s*$", title_line)
if not match:
    raise SystemExit(f"Could not find story title heading in {story_path}")

epic_num, story_num, story_title = match.groups()
story_key = story_path.stem

start = None
end = None
has_acceptance_criteria = False
for index, line in enumerate(lines):
    if line == "## Story":
        start = index
    elif start is not None and line == "## Tasks / Subtasks":
        end = index
        break
    elif start is not None and line == "## Acceptance Criteria":
        has_acceptance_criteria = True

if start is None:
    raise SystemExit(f"Could not find ## Story section in {story_path}")
if not has_acceptance_criteria:
    raise SystemExit(f"Could not find ## Acceptance Criteria section in {story_path}")
if end is None:
    raise SystemExit(f"Could not find ## Tasks / Subtasks boundary in {story_path}")

section = lines[start:end]
section_text = "\n".join(section).strip()
if "As a " not in section_text or "## Acceptance Criteria" not in section_text:
    raise SystemExit(f"Story details are not populated in {story_path}")

body = "\n".join(
    [
        f"Source: `{story_path.as_posix()}`",
        "",
        f"Tracking key: `{story_key}`",
        "",
        f"Epic: {epic_num}",
        "",
        "Current status: in-progress",
        "",
        *section,
        "",
    ]
)
body_path.write_text(body, encoding="utf-8")

print("\t".join([epic_num, f"{epic_num}.{story_num}", story_title, story_key]))
PY
)"

IFS=$'\t' read -r epic_num story_id story_title story_key <<< "$story_meta"
issue_title="Story $story_id: $story_title"

issue_number="$(
  gh issue list \
    --repo "$REPO_FULL_NAME" \
    --state all \
    --search "$issue_title in:title" \
    --json number,title \
    --jq ".[] | select(.title == \"$issue_title\") | .number" \
    --limit 50 |
    head -n 1
)"

if [[ -z "$issue_number" ]]; then
  echo "GitHub issue not found: $issue_title"
  exit 1
fi

gh label create "status:in-progress" \
  --repo "$REPO_FULL_NAME" \
  --color "C5DEF5" \
  --description "BMad status: in-progress" \
  --force >/dev/null

project_number="$(
  gh project list \
    --owner "$OWNER" \
    --format json \
    --jq ".projects[] | select(.title == \"$PROJECT_TITLE\") | .number" |
    head -n 1
)"

if [[ -z "$project_number" ]]; then
  echo "GitHub Project not found: $PROJECT_TITLE"
  echo "Run: scripts/github/create-sprint-project.sh"
  exit 1
fi

project_id="$(gh project view "$project_number" --owner "$OWNER" --format json --jq '.id')"
status_field_id="$(
  gh project field-list "$project_number" \
    --owner "$OWNER" \
    --format json \
    --jq '.fields[] | select(.name == "Status") | .id'
)"
in_progress_option_id="$(
  gh project field-list "$project_number" \
    --owner "$OWNER" \
    --format json \
    --jq '.fields[] | select(.name == "Status") | .options[] | select(.name == "In Progress") | .id'
)"

if [[ -z "$project_id" || -z "$status_field_id" || -z "$in_progress_option_id" ]]; then
  echo "Could not resolve GitHub Project Status field or In Progress option."
  exit 1
fi

item_id="$(
  gh project item-list "$project_number" \
    --owner "$OWNER" \
    --format json \
    --limit 500 \
    --jq ".items[] | select(.content.number == $issue_number) | .id" |
    head -n 1
)"

if [[ -z "$item_id" ]]; then
  issue_url="$(gh issue view "$issue_number" --repo "$REPO_FULL_NAME" --json url --jq '.url')"
  gh project item-add "$project_number" --owner "$OWNER" --url "$issue_url" >/dev/null
  item_id="$(
    gh project item-list "$project_number" \
      --owner "$OWNER" \
      --format json \
      --limit 500 \
      --jq ".items[] | select(.content.number == $issue_number) | .id" |
      head -n 1
  )"
fi

gh issue edit "$issue_number" --repo "$REPO_FULL_NAME" --body-file "$tmp_body" >/dev/null

for label in \
  "status: backlog" \
  "status: ready" \
  "status: in-progress" \
  "status: review" \
  "status: done" \
  "status:backlog" \
  "status:ready" \
  "status:review" \
  "status:done"; do
  gh issue edit "$issue_number" --repo "$REPO_FULL_NAME" --remove-label "$label" >/dev/null 2>&1 || true
done
gh issue edit "$issue_number" --repo "$REPO_FULL_NAME" --add-label "status:in-progress" >/dev/null

gh project item-edit \
  --id "$item_id" \
  --project-id "$project_id" \
  --field-id "$status_field_id" \
  --single-select-option-id "$in_progress_option_id" >/dev/null

echo "Started $issue_title (#$issue_number): issue body synced and Project Status set to In Progress."
