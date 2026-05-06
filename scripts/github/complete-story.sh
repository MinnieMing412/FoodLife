#!/usr/bin/env bash
set -euo pipefail

STORY_FILE="${1:-${STORY_FILE:-}}"
SPRINT_STATUS_FILE="${SPRINT_STATUS_FILE:-_bmad-output/implementation-artifacts/sprint-status.yaml}"
BASE_BRANCH="${BASE_BRANCH:-main}"
PROJECT_TITLE="${PROJECT_TITLE:-FoodLife Sprint Tracking}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed. Install GitHub CLI first: https://cli.github.com/"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git worktree."
  exit 1
fi

gh auth status -h github.com >/dev/null

branch="$(git branch --show-current)"
if [[ -z "$branch" ]]; then
  echo "Could not determine current git branch."
  exit 1
fi

if [[ "$branch" == "$BASE_BRANCH" || "$branch" == "main" || "$branch" == "master" ]]; then
  echo "Refusing to complete a story directly on '$branch'. Create a story branch first."
  exit 1
fi

remote_url="$(git remote get-url origin)"
case "$remote_url" in
  git@github.com:*.git)
    REPOSITORY="${remote_url#git@github.com:}"
    REPOSITORY="${REPOSITORY%.git}"
    ;;
  https://github.com/*.git)
    REPOSITORY="${remote_url#https://github.com/}"
    REPOSITORY="${REPOSITORY%.git}"
    ;;
  https://github.com/*)
    REPOSITORY="${remote_url#https://github.com/}"
    ;;
  *)
    REPOSITORY="${GITHUB_REPOSITORY:-}"
    ;;
esac

if [[ -z "$REPOSITORY" ]]; then
  echo "Could not infer GitHub repository from origin remote. Set GITHUB_REPOSITORY=owner/repo."
  exit 1
fi

OWNER="${GITHUB_OWNER:-${REPOSITORY%%/*}}"
REPO="${GITHUB_REPO:-${REPOSITORY#*/}}"
REPO_FULL_NAME="$OWNER/$REPO"

if [[ -z "$STORY_FILE" ]]; then
  if [[ ! -f "$SPRINT_STATUS_FILE" ]]; then
    echo "Story file was not provided and sprint status file was not found: $SPRINT_STATUS_FILE"
    exit 1
  fi

  story_key="$(
    awk '
      $0 == "development_status:" { in_status = 1; next }
      in_status && $0 !~ /^  / { exit }
      in_status && ($2 == "review" || $2 == "in-progress") && $1 !~ /^epic-/ && $1 !~ /-retrospective:$/ {
        key = $1
        sub(/:$/, "", key)
        print key
        exit
      }
    ' "$SPRINT_STATUS_FILE"
  )"

  if [[ -z "$story_key" ]]; then
    echo "No review or in-progress story found in $SPRINT_STATUS_FILE"
    exit 1
  fi

  STORY_FILE="_bmad-output/implementation-artifacts/${story_key}.md"
fi

if [[ ! -f "$STORY_FILE" ]]; then
  echo "Story file not found: $STORY_FILE"
  exit 1
fi

tmp_meta="$(mktemp)"
tmp_pr_body="$(mktemp)"
tmp_issue_body="$(mktemp)"
trap 'rm -f "$tmp_meta" "$tmp_pr_body" "$tmp_issue_body"' EXIT

python3 - "$STORY_FILE" "$SPRINT_STATUS_FILE" "$tmp_meta" <<'PY'
import json
import re
import sys
from datetime import datetime
from pathlib import Path

story_path = Path(sys.argv[1])
status_path = Path(sys.argv[2])
meta_path = Path(sys.argv[3])

text = story_path.read_text(encoding="utf-8")
lines = text.splitlines()

title_line = next((line for line in lines if line.startswith("# Story ")), "")
match = re.match(r"^# Story (\d+)\.(\d+):\s*(.+?)\s*$", title_line)
if not match:
    raise SystemExit(f"Could not find story title heading in {story_path}")

epic_num, story_num, story_title = match.groups()
story_id = f"{epic_num}.{story_num}"
story_key = story_path.stem

def set_status_done(content: str) -> str:
    content = re.sub(r"(?m)^Status:\s*\S+\s*$", "Status: done", content, count=1)
    return content

def section(name: str) -> str:
    pattern = rf"(?ms)^### {re.escape(name)}\n\n(.*?)(?=^### |\Z)"
    section_match = re.search(pattern, text)
    return section_match.group(1).strip() if section_match else ""

completion_notes = section("Completion Notes List")
change_log = section("Change Log")

text = set_status_done(text)
story_path.write_text(text + ("" if text.endswith("\n") else "\n"), encoding="utf-8")

if status_path.exists():
    status_text = status_path.read_text(encoding="utf-8")
    status_text = re.sub(
        rf"(?m)^(\s{{2}}{re.escape(story_key)}:\s*)\S+\s*$",
        rf"\1done",
        status_text,
        count=1,
    )
    stamp = datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z")
    status_text = re.sub(r"(?m)^# last_updated: .*$", f"# last_updated: {stamp}", status_text, count=1)
    status_text = re.sub(r"(?m)^last_updated: .*$", f"last_updated: {stamp}", status_text, count=1)
    status_path.write_text(status_text, encoding="utf-8")

meta_path.write_text(
    json.dumps(
        {
            "story_id": story_id,
            "story_key": story_key,
            "story_title": story_title,
            "issue_title": f"Story {story_id}: {story_title}",
            "completion_notes": completion_notes,
            "change_log": change_log,
            "story_file": story_path.as_posix(),
        }
    ),
    encoding="utf-8",
)
PY

story_id="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["story_id"])' "$tmp_meta")"
story_title="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["story_title"])' "$tmp_meta")"
issue_title="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["issue_title"])' "$tmp_meta")"

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "Complete Story $story_id: $story_title"
  fi
fi

git push -u origin "$branch"

pr_url="$(
  gh pr list \
    --repo "$REPO_FULL_NAME" \
    --head "$branch" \
    --base "$BASE_BRANCH" \
    --json url \
    --jq '.[0].url // ""'
)"

if [[ -z "$pr_url" ]]; then
  python3 - "$tmp_meta" "$tmp_pr_body" <<'PY'
import json
import sys
from pathlib import Path

meta = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
body_path = Path(sys.argv[2])

body_path.write_text(
    "\n".join(
        [
            "## Summary",
            "",
            f"- Completes Story {meta['story_id']}: {meta['story_title']}.",
            f"- Updates `{meta['story_file']}` to `done`.",
            "- Syncs the corresponding GitHub story/project status through the completion hook.",
            "",
            "## Completion Notes",
            "",
            meta.get("completion_notes") or "- See the story file for implementation notes.",
            "",
            "## Validation",
            "",
            "- See the story file completion notes and Dev Agent Record.",
            "",
        ]
    ),
    encoding="utf-8",
)
PY
  pr_url="$(
    gh pr create \
      --repo "$REPO_FULL_NAME" \
      --draft \
      --base "$BASE_BRANCH" \
      --head "$branch" \
      --title "Story $story_id: $story_title" \
      --body-file "$tmp_pr_body"
  )"
fi

python3 - "$STORY_FILE" "$tmp_meta" "$tmp_issue_body" "$pr_url" "$branch" "$BASE_BRANCH" <<'PY'
import json
import re
import sys
from pathlib import Path

story_path = Path(sys.argv[1])
meta = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
issue_body_path = Path(sys.argv[3])
pr_url = sys.argv[4]
branch = sys.argv[5]
base_branch = sys.argv[6]

text = story_path.read_text(encoding="utf-8")

pull_request_block = "\n".join(
    [
        "### Pull Request",
        "",
        f"- Draft PR: {pr_url}",
        f"- PR branch: `{branch}`",
        f"- PR target: `{base_branch}`",
        "",
    ]
)

if re.search(r"(?ms)^### Pull Request\n\n.*?(?=^### |\Z)", text):
    text = re.sub(r"(?ms)^### Pull Request\n\n.*?(?=^### |\Z)", pull_request_block, text, count=1)
else:
    marker = "## Dev Notes"
    if marker in text:
        text = text.replace(marker, pull_request_block + marker, 1)
    else:
        text += "\n\n" + pull_request_block

story_path.write_text(text + ("" if text.endswith("\n") else "\n"), encoding="utf-8")

completed = meta.get("completion_notes") or "See the story file for completion notes."
issue_body = "\n".join(
    [
        f"Source: `{meta['story_file']}`",
        "",
        f"Tracking key: `{meta['story_key']}`",
        "",
        f"Epic: {meta['story_id'].split('.')[0]}",
        "",
        "Current status: done",
        "",
        f"PR: {pr_url}",
        "",
        "## Completed",
        "",
        completed,
        "",
    ]
)
issue_body_path.write_text(issue_body, encoding="utf-8")
PY

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

if [[ -n "$issue_number" ]]; then
  gh issue edit "$issue_number" --repo "$REPO_FULL_NAME" --body-file "$tmp_issue_body" >/dev/null
fi

git add "$STORY_FILE"
if [[ -f "$SPRINT_STATUS_FILE" ]]; then
  git add "$SPRINT_STATUS_FILE"
fi
if ! git diff --cached --quiet; then
  git commit -m "Record Story $story_id PR link"
  git push
fi

scripts/github/sync-sprint-status.sh

echo "Completed Story $story_id: $story_title"
echo "PR: $pr_url"
