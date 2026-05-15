# Story 1.3: Establish Baseline CI and Verification Workflow

Status: done
<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a FoodLife developer,
I want schema-contract and web verification to run through documented commands and baseline CI,
so that implementation agents get fast feedback before feature work depends on the foundation.

## Acceptance Criteria

1. Given the web app starter and schema-contract package exist, when baseline verification is configured, then the repository exposes documented commands for web install, typecheck, test, and build.
2. The schema-contract package exposes a documented validation/test command for fixtures and expected outputs.
3. Baseline CI or equivalent repository automation runs schema-contract validation and web typecheck/test/build.
4. iOS build/test automation is added when an Xcode-capable CI runner is available, or the local Xcode verification path is documented.
5. No backend deployment, cloud service, or non-MVP infrastructure is introduced.

## Tasks / Subtasks

- [x] Audit the existing baseline workflow before editing it (AC: 3, 4, 5)
  - [x] Read `.github/workflows/test-suite.yml` completely and preserve the current `Test Suite` intent unless a failing verification proves a change is needed.
  - [x] Confirm the `web-and-schema` job installs and verifies `apps/web` and `packages/schema-contract` without coupling either package to backend/cloud infrastructure.
  - [x] Confirm the `ios` job remains Xcode-capable and uses simulator selection that is not tied to a single unavailable simulator name.
  - [x] Keep workflow permissions minimal for read-only validation; do not add write permissions, secrets, deployment jobs, or release steps.
- [x] Document canonical local verification commands (AC: 1, 2, 4)
  - [x] Update the root `README.md` so web verification includes `npm install`, `npm run test`, `npm run lint`, and `npm run build` from `apps/web`.
  - [x] Update the root `README.md` so schema-contract verification includes `npm install`, `npm test`, `npm run validate`, and `npm run generate:schema` from `packages/schema-contract`.
  - [x] Add or refresh an iOS verification section that documents the local Xcode build/test path and the GitHub Actions macOS CI path.
  - [x] Remove stale wording that says `packages/schema-contract` is still a placeholder.
- [x] Harden or adjust CI only where the audit finds gaps (AC: 3, 4, 5)
  - [x] Ensure web CI executes install, tests, lint/typecheck coverage via the existing build command, and production build.
  - [x] Ensure schema CI executes tests, validation, and generated JSON Schema freshness checks.
  - [x] Ensure iOS CI either builds and runs unit tests on GitHub-hosted macOS or clearly documents why only local verification is currently supported.
  - [x] Avoid adding backend deployment, cloud hosting, authentication, sync, package publishing, or unused infrastructure placeholders.
- [x] Run and record verification results (AC: 1-4)
  - [x] Run the schema-contract commands from `packages/schema-contract`: `npm test`, `npm run validate`, and `npm run generate:schema` followed by a diff check for the generated schema.
  - [x] Run the web commands from `apps/web`: `npm run test`, `npm run lint`, and `npm run build`.
  - [x] Run local iOS verification when Xcode and simulator services are available, or record the exact local command and the environment limitation if unavailable.
  - [x] If GitHub Actions is available after pushing the story branch, record the workflow run URL and final status in the Dev Agent Record.

## Dev Notes

### Current Repository State

- Local `main` has already been fast-forwarded to `origin/main` at `5f90e1f` before this story was created.
- `.github/workflows/test-suite.yml` already exists and was introduced by commit `5f90e1f Add CI test workflow (#43)`. Treat it as the starting point for Story 1.3, not as absent infrastructure. [Source: `.github/workflows/test-suite.yml`; `git log --oneline -5`]
- The workflow currently runs on `push` to `main`, `codex/**`, `dev/**`, and `feature/**`, plus `workflow_dispatch`. It has `permissions: contents: read` and contains two jobs: `web-and-schema` on `ubuntu-latest` and `ios` on `macos-latest`. [Source: `.github/workflows/test-suite.yml`]
- The web package already exposes `test`, `lint`, and `build`; `build` runs `tsc -b && vite build`, which is the current typecheck plus production build path. [Source: `apps/web/package.json`]
- The schema-contract package already exposes `test`, `validate`, and `generate:schema`. `validate` is currently an alias for `vitest run`. [Source: `packages/schema-contract/package.json`]
- Root `README.md` is stale in two important ways: it does not document web lint, schema-contract validation/generation, or the current CI workflow; it also still says `packages/schema-contract` is a placeholder until Story 1.2. [Source: `README.md`]

### Story Scope

- This story is about baseline verification and developer feedback loops. It may update `.github/workflows/test-suite.yml`, root documentation, and small package command documentation, but should not implement new product behavior.
- Because CI already exists on `main`, the most likely implementation work is documentation cleanup, command audit, CI hardening, and recording verified results.
- Do not create separate duplicate workflow files unless there is a concrete reason. The current repository has only `.github/workflows/test-suite.yml`; the architecture examples mention `web-ci.yml` and `schema-contract-ci.yml`, but the merged implementation currently uses a consolidated workflow. [Source: `_bmad-output/planning-artifacts/architecture.md` > Complete Project Directory Structure; `.github/workflows/test-suite.yml`]

### CI and Verification Requirements

- Web CI direction from architecture: install, typecheck, test, and build. The current package-level command mapping is `npm ci`, `npm run test`, `npm run lint`, and `npm run build` from `apps/web`; `npm run build` performs TypeScript build mode before Vite build. [Source: `_bmad-output/planning-artifacts/architecture.md` > Infrastructure & Deployment; `apps/web/package.json`]
- Schema contract CI direction from architecture: validate fixtures and expected conformance outputs before app implementation proceeds. The current command mapping is `npm ci`, `npm run test`, `npm run validate`, and `npm run generate:schema` plus a diff check for `schemas/food-memory-v1.schema.json`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Infrastructure & Deployment; `.github/workflows/test-suite.yml`; `packages/schema-contract/package.json`]
- iOS CI direction from architecture: build and test when CI environment supports Xcode. The current workflow uses `macos-latest`, selects an available iPhone simulator, builds test bundles, boots the simulator, and runs only `FoodLifeTests` with `test-without-building`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Infrastructure & Deployment; `.github/workflows/test-suite.yml`]
- Keep CI minimal. MVP has no backend service, database server, authentication provider, object storage, server-side rendering, package publishing, or deployment automation. [Source: `_bmad-output/planning-artifacts/architecture.md` > Infrastructure & Deployment]

### Existing Files to Read Before Changing

- `.github/workflows/test-suite.yml`: current consolidated CI workflow. Preserve branch filters, minimal permissions, and the current split between `web-and-schema` and `ios` unless the verification audit proves a better structure is needed.
- `README.md`: root developer command documentation. This is likely the main UPDATE file for the story because it is stale after Story 1.2 and the CI workflow merge.
- `apps/web/package.json`: current web scripts and dependencies. Do not add scripts unless there is a concrete documentation or CI readability need.
- `packages/schema-contract/package.json` and `packages/schema-contract/README.md`: current schema scripts and package-local documentation. Avoid changing schema behavior in this story.

### Previous Story Intelligence

- Story 1.2 completed the isolated `@foodlife/schema-contract` package with Zod validation, generated JSON Schema, valid and invalid fixtures, expected timeline/seasonal conformance seeds, migration notes, and Vitest coverage. Do not recreate this package or move it into the web app. [Source: `_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md` > Completion Notes List]
- Story 1.2 verified `npm test` and `npm run validate` from `packages/schema-contract`, plus `npm run test`, `npm run lint`, and `npm run build` from `apps/web`. Use these as the baseline local command set, then rerun them for this story. [Source: `_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md` > Completion Notes List]
- Story 1.2 recorded that iOS `xcodebuild build-for-testing` succeeded locally with an explicit simulator OS before CI optimization. Current CI should not assume that exact local simulator name/OS always exists on hosted runners. [Source: `_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md` > Debug Log References]
- Recent commit `5f90e1f` added the consolidated CI workflow after Story 1.2. The dev agent should audit and document that merged work rather than accidentally deleting it as "pre-existing noise." [Source: `git show --stat --oneline 5f90e1f`]

### Latest Technical Information

- GitHub Actions workflow syntax supports explicit `permissions` values such as `contents: read`, `write`, or `none`; this story should keep read-only token permissions for validation-only CI. [Source: https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions]
- `actions/setup-node` supports npm caching and uses dependency file hashes for cache keys; the current workflow correctly provides both package lockfiles in `cache-dependency-path`. [Source: https://github.com/actions/setup-node]
- GitHub-hosted `-latest` runner labels point to GitHub's latest stable image and can change over time, so iOS CI should select available simulator devices dynamically or document pinned-runner tradeoffs if stability becomes an issue. [Source: https://docs.github.com/en/actions/reference/github-hosted-runners-reference; https://github.com/actions/runner-images]

### Anti-Patterns to Avoid

- Do not add backend deployment, cloud hosting, package publishing, auth setup, sync jobs, or secrets for this foundation story.
- Do not duplicate validation work by creating multiple CI workflows that run the same package commands without a clear reason.
- Do not remove schema JSON freshness checks unless they are replaced by an equivalent contract drift guard.
- Do not treat a local manual web launch as a substitute for package tests, lint/typecheck, schema validation, and CI results.
- Do not mark the story complete without recording exact commands and results in the Dev Agent Record.

### References

- `_bmad-output/planning-artifacts/epics.md` > Story 1.3
- `_bmad-output/planning-artifacts/architecture.md` > Infrastructure & Deployment
- `_bmad-output/planning-artifacts/architecture.md` > Development Workflow Integration
- `_bmad-output/planning-artifacts/architecture.md` > Process Patterns
- `_bmad-output/planning-artifacts/prd.md` > Technical Success and NFR16/NFR23
- `_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md` > Previous story learnings
- `.github/workflows/test-suite.yml`
- `README.md`
- `apps/web/package.json`
- `packages/schema-contract/package.json`
- `packages/schema-contract/README.md`
- https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions
- https://github.com/actions/setup-node
- https://docs.github.com/en/actions/reference/github-hosted-runners-reference
- https://github.com/actions/runner-images

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Debug Log References

- `STORY_FILE="_bmad-output/implementation-artifacts/1-3-establish-baseline-ci-and-verification-workflow.md" scripts/github/start-story.sh` failed in the restricted sandbox with `error connecting to api.github.com`; reran with approved network access and GitHub CLI reported the token is missing `read:project`. Required fix: `gh auth refresh -s read:project`.
- `STORY_FILE="_bmad-output/implementation-artifacts/1-3-establish-baseline-ci-and-verification-workflow.md" scripts/github/start-story.sh` then reported the token was missing `project`; after auth refresh, the command succeeded and synced GitHub issue #9 / Project status to In Progress.
- `npm run generate:schema` in `packages/schema-contract` failed in the restricted sandbox because `tsx` could not create its temporary IPC pipe under `/var/folders/.../T/tsx-501/*.pipe`; reran with approved local execution and it passed.
- `xcodebuild test-without-building ... -destination 'generic/platform=iOS Simulator' ... -only-testing:FoodLifeTests` failed because CoreSimulatorService is unavailable in this environment and tests require a concrete simulator device. The build-for-testing command succeeded.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Audited the consolidated `Test Suite` workflow and preserved its read-only permissions, web/schema validation jobs, and macOS iOS build/unit-test job.
- Added `dev-*` to the workflow push branch filters so this story branch convention triggers baseline CI on push.
- Updated the root README with current web, schema-contract, iOS, and GitHub Actions verification instructions.
- Removed stale README wording that described `packages/schema-contract` as a placeholder.
- Verified schema-contract tests and validation pass, regenerated the JSON Schema artifact, and confirmed the generated schema has no diff.
- Verified web tests, lint, and build pass.
- Verified local iOS `build-for-testing` passes; local simulator-backed unit test execution is blocked by unavailable CoreSimulatorService in this environment.

### File List

- `.github/workflows/test-suite.yml`
- `README.md`
- `_bmad-output/implementation-artifacts/1-3-establish-baseline-ci-and-verification-workflow.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-05-14: Implemented Story 1.3 baseline CI/docs hardening and recorded verification results.
