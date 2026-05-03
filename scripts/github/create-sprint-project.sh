#!/usr/bin/env bash
set -euo pipefail

OWNER="${GITHUB_OWNER:-MinnieMing412}"
REPO="${GITHUB_REPO:-FoodLife}"
PROJECT_TITLE="${PROJECT_TITLE:-FoodLife Sprint Tracking}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh is not installed. Install GitHub CLI first: https://cli.github.com/"
  exit 1
fi

gh auth status >/dev/null

echo "Creating labels..."
gh label create "type: epic" --repo "$OWNER/$REPO" --color "5319E7" --description "Epic-level planning issue" --force
gh label create "type: story" --repo "$OWNER/$REPO" --color "1D76DB" --description "Implementable user story" --force
gh label create "status: backlog" --repo "$OWNER/$REPO" --color "C5DEF5" --description "Not started" --force
gh label create "status: ready" --repo "$OWNER/$REPO" --color "0E8A16" --description "Ready for development" --force
gh label create "status: in-progress" --repo "$OWNER/$REPO" --color "FBCA04" --description "Actively being worked" --force
gh label create "status: review" --repo "$OWNER/$REPO" --color "D93F0B" --description "Ready for review" --force
gh label create "status: done" --repo "$OWNER/$REPO" --color "0E8A16" --description "Complete" --force

for epic in 1 2 3 4 5 6; do
  gh label create "epic:$epic" --repo "$OWNER/$REPO" --color "BFDADC" --description "Epic $epic" --force
done

echo "Creating sprint milestones..."
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

create_milestone "Sprint 1 - Foundation" "Epic 1: local-first app shells, schema, repository/photo boundaries, navigation, tokens, and verification."
create_milestone "Sprint 2 - Capture" "Epic 2: type-first Add Memory, photo entry, Made/Found creation, and persistence validation."
create_milestone "Sprint 3 - Made" "Epic 3: Made gallery, states, detail, accessibility, and responsiveness."
create_milestone "Sprint 4 - Found" "Epic 4: Found map, preview, fallback, detail, accessibility, and responsiveness."
create_milestone "Sprint 5 - Edit" "Epic 5: edit mode, metadata updates, photo replacement/preservation, and related view refresh."
create_milestone "Sprint 6 - Home & Timeline" "Epic 6: seasonal recap, Home, Timeline, detail routing, accessibility, and responsiveness."

echo "Creating GitHub Project..."
PROJECT_NUMBER="$(gh project list --owner "$OWNER" --format json --jq ".projects[] | select(.title == \"$PROJECT_TITLE\") | .number" | head -n 1)"
if [[ -z "$PROJECT_NUMBER" ]]; then
  PROJECT_NUMBER="$(gh project create --owner "$OWNER" --title "$PROJECT_TITLE" --format json --jq '.number')"
fi
echo "Project number: $PROJECT_NUMBER"

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
    gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$existing_url" >/dev/null || true
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
  gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$url" >/dev/null
}

story_body() {
  local story_id="$1"
  local epic="$2"
  local status_key="$3"
  cat <<EOF
Source: _bmad-output/planning-artifacts/epics.md

Tracking key: \`$status_key\`
Epic: $epic
Initial status: backlog

Use this issue as the implementation tracking item for story $story_id.
EOF
}

epic_body() {
  local epic="$1"
  local summary="$2"
  cat <<EOF
Source: _bmad-output/planning-artifacts/epics.md

$summary

Use child story issues and the sprint milestone to track implementation progress.
EOF
}

echo "Creating epic issues..."
create_issue "Epic 1: Local-First FoodLife Foundation" "$(epic_body 1 "Users can open complete iOS and web app shells, navigate the core product structure, and rely on a shared local-first FoodMemory model.")" "Sprint 1 - Foundation" "type: epic" "epic:1" "status: backlog"
create_issue "Epic 2: Photo-First Memory Capture" "$(epic_body 2 "Users can start Add Memory globally, choose Made or Found first, attach or capture a photo, complete type-specific fields, and save local memories.")" "Sprint 2 - Capture" "type: epic" "epic:2" "status: backlog"
create_issue "Epic 3: Made Memories Gallery and Detail" "$(epic_body 3 "Users can browse Made memories in a warm gallery-first experience and open Made detail views.")" "Sprint 3 - Made" "type: epic" "epic:3" "status: backlog"
create_issue "Epic 4: Found Memories Map and Detail" "$(epic_body 4 "Users can browse Found memories through a map-first place-aware experience and open Found detail views.")" "Sprint 4 - Found" "type: epic" "epic:4" "status: backlog"
create_issue "Epic 5: Edit and Maintain Memories" "$(epic_body 5 "Users can correct or complete Made and Found memories later while preserving unchanged fields and photo associations.")" "Sprint 5 - Edit" "type: epic" "epic:5" "status: backlog"
create_issue "Epic 6: Home Seasonal Reflection and Timeline Rediscovery" "$(epic_body 6 "Users can rediscover their food life through a seasonal Home recap and chronological Timeline.")" "Sprint 6 - Home & Timeline" "type: epic" "epic:6" "status: backlog"

echo "Creating story issues..."
create_issue "Story 1.1: Set Up Initial Project from Starter Templates" "$(story_body "1.1" "Epic 1" "1-1-set-up-initial-project-from-starter-templates")" "Sprint 1 - Foundation" "type: story" "epic:1" "status: backlog"
create_issue "Story 1.2: Define FoodMemory v1 Schema Contract" "$(story_body "1.2" "Epic 1" "1-2-define-foodmemory-v1-schema-contract")" "Sprint 1 - Foundation" "type: story" "epic:1" "status: backlog"
create_issue "Story 1.3: Establish Baseline CI and Verification Workflow" "$(story_body "1.3" "Epic 1" "1-3-establish-baseline-ci-and-verification-workflow")" "Sprint 1 - Foundation" "type: story" "epic:1" "status: backlog"
create_issue "Story 1.4: Implement Web Local Repository Contract" "$(story_body "1.4" "Epic 1" "1-4-implement-web-local-repository-contract")" "Sprint 1 - Foundation" "type: story" "epic:1" "status: backlog"
create_issue "Story 1.5: Implement Web Photo Reference Store Boundary" "$(story_body "1.5" "Epic 1" "1-5-implement-web-photo-reference-store-boundary")" "Sprint 1 - Foundation" "type: story" "epic:1" "status: backlog"
create_issue "Story 1.6: Implement iOS Domain and Repository Contract" "$(story_body "1.6" "Epic 1" "1-6-implement-ios-domain-and-repository-contract")" "Sprint 1 - Foundation" "type: story" "epic:1" "status: backlog"
create_issue "Story 1.7: Establish Shared Navigation and Design Tokens" "$(story_body "1.7" "Epic 1" "1-7-establish-shared-navigation-and-design-tokens")" "Sprint 1 - Foundation" "type: story" "epic:1" "status: backlog"

create_issue "Story 2.1: Launch Type-First Add Memory Flow" "$(story_body "2.1" "Epic 2" "2-1-launch-type-first-add-memory-flow")" "Sprint 2 - Capture" "type: story" "epic:2" "status: backlog"
create_issue "Story 2.2: Add Photo Picker Entry Point" "$(story_body "2.2" "Epic 2" "2-2-add-photo-picker-entry-point")" "Sprint 2 - Capture" "type: story" "epic:2" "status: backlog"
create_issue "Story 2.3: Create Made Memory with Required and Optional Context" "$(story_body "2.3" "Epic 2" "2-3-create-made-memory-with-required-and-optional-context")" "Sprint 2 - Capture" "type: story" "epic:2" "status: backlog"
create_issue "Story 2.4: Create Found Memory with Location and Discovery Context" "$(story_body "2.4" "Epic 2" "2-4-create-found-memory-with-location-and-discovery-context")" "Sprint 2 - Capture" "type: story" "epic:2" "status: backlog"
create_issue "Story 2.5: Preserve Found Memory When Location Services Fail" "$(story_body "2.5" "Epic 2" "2-5-preserve-found-memory-when-location-services-fail")" "Sprint 2 - Capture" "type: story" "epic:2" "status: backlog"
create_issue "Story 2.6: Validate Capture Persistence Across Web and iOS" "$(story_body "2.6" "Epic 2" "2-6-validate-capture-persistence-across-web-and-ios")" "Sprint 2 - Capture" "type: story" "epic:2" "status: backlog"

create_issue "Story 3.1: Browse Made Memories in a Gallery" "$(story_body "3.1" "Epic 3" "3-1-browse-made-memories-in-a-gallery")" "Sprint 3 - Made" "type: story" "epic:3" "status: backlog"
create_issue "Story 3.2: Support Made Empty, Loading, and Error States" "$(story_body "3.2" "Epic 3" "3-2-support-made-empty-loading-and-error-states")" "Sprint 3 - Made" "type: story" "epic:3" "status: backlog"
create_issue "Story 3.3: Open Made Memory Detail View" "$(story_body "3.3" "Epic 3" "3-3-open-made-memory-detail-view")" "Sprint 3 - Made" "type: story" "epic:3" "status: backlog"
create_issue "Story 3.4: Make Made Browse and Detail Accessible and Responsive" "$(story_body "3.4" "Epic 3" "3-4-make-made-browse-and-detail-accessible-and-responsive")" "Sprint 3 - Made" "type: story" "epic:3" "status: backlog"

create_issue "Story 4.1: Browse Found Memories on a Map" "$(story_body "4.1" "Epic 4" "4-1-browse-found-memories-on-a-map")" "Sprint 4 - Found" "type: story" "epic:4" "status: backlog"
create_issue "Story 4.2: Open Found Map Memory Preview" "$(story_body "4.2" "Epic 4" "4-2-open-found-map-memory-preview")" "Sprint 4 - Found" "type: story" "epic:4" "status: backlog"
create_issue "Story 4.3: Provide Found Map Fallback and Accessible Alternative" "$(story_body "4.3" "Epic 4" "4-3-provide-found-map-fallback-and-accessible-alternative")" "Sprint 4 - Found" "type: story" "epic:4" "status: backlog"
create_issue "Story 4.4: Open Found Memory Detail View" "$(story_body "4.4" "Epic 4" "4-4-open-found-memory-detail-view")" "Sprint 4 - Found" "type: story" "epic:4" "status: backlog"
create_issue "Story 4.5: Make Found Map and Detail Accessible and Responsive" "$(story_body "4.5" "Epic 4" "4-5-make-found-map-and-detail-accessible-and-responsive")" "Sprint 4 - Found" "type: story" "epic:4" "status: backlog"

create_issue "Story 5.1: Enter Edit Mode from Memory Detail" "$(story_body "5.1" "Epic 5" "5-1-enter-edit-mode-from-memory-detail")" "Sprint 5 - Edit" "type: story" "epic:5" "status: backlog"
create_issue "Story 5.2: Edit Made Memory Metadata" "$(story_body "5.2" "Epic 5" "5-2-edit-made-memory-metadata")" "Sprint 5 - Edit" "type: story" "epic:5" "status: backlog"
create_issue "Story 5.3: Edit Found Memory Metadata" "$(story_body "5.3" "Epic 5" "5-3-edit-found-memory-metadata")" "Sprint 5 - Edit" "type: story" "epic:5" "status: backlog"
create_issue "Story 5.4: Replace or Preserve Memory Photo" "$(story_body "5.4" "Epic 5" "5-4-replace-or-preserve-memory-photo")" "Sprint 5 - Edit" "type: story" "epic:5" "status: backlog"
create_issue "Story 5.5: Confirm Update and Refresh Related Views" "$(story_body "5.5" "Epic 5" "5-5-confirm-update-and-refresh-related-views")" "Sprint 5 - Edit" "type: story" "epic:5" "status: backlog"

create_issue "Story 6.1: Generate Seasonal Recap from Local Memories" "$(story_body "6.1" "Epic 6" "6-1-generate-seasonal-recap-from-local-memories")" "Sprint 6 - Home & Timeline" "type: story" "epic:6" "status: backlog"
create_issue "Story 6.2: Present Home Seasonal Reflection Experience" "$(story_body "6.2" "Epic 6" "6-2-present-home-seasonal-reflection-experience")" "Sprint 6 - Home & Timeline" "type: story" "epic:6" "status: backlog"
create_issue "Story 6.3: Browse All Memories in Chronological Timeline" "$(story_body "6.3" "Epic 6" "6-3-browse-all-memories-in-chronological-timeline")" "Sprint 6 - Home & Timeline" "type: story" "epic:6" "status: backlog"
create_issue "Story 6.4: Open Memory Details from Timeline and Home" "$(story_body "6.4" "Epic 6" "6-4-open-memory-details-from-timeline-and-home")" "Sprint 6 - Home & Timeline" "type: story" "epic:6" "status: backlog"
create_issue "Story 6.5: Make Home and Timeline Responsive and Accessible" "$(story_body "6.5" "Epic 6" "6-5-make-home-and-timeline-responsive-and-accessible")" "Sprint 6 - Home & Timeline" "type: story" "epic:6" "status: backlog"

echo "Done."
echo "Open: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
