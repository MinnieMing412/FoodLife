# Story 1.2: Define FoodMemory v1 Schema Contract

Status: done
<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a FoodLife user,
I want Made and Found memories to share a consistent model,
so that my archive behaves the same on iOS and web.

## Acceptance Criteria

1. Given the schema contract package exists, when FoodMemory v1 is defined, then it includes common fields, Made metadata, Found metadata, `schemaVersion`, string IDs, ISO 8601 dates, and `type` discriminator values of `made` or `found`.
2. Photo references are modeled separately from memory metadata through `photoRefs`; memory records never embed image blobs.
3. Valid Made and Found fixtures are included and validate against the FoodMemory v1 contract.
4. Invalid fixtures cover unsupported `type` values and missing required shared fields, and tests prove those fixtures fail validation.
5. Schema contract tests verify fixtures and fail on contract violations.
6. Migration notes and expected conformance outputs needed by later timeline/seasonal/repository stories are added under the schema-contract package without implementing platform repositories or UI.

## Tasks / Subtasks

- [x] Create the schema-contract package scaffolding (AC: 1, 5, 6)
  - [x] Add `packages/schema-contract/package.json` with scripts for validation/tests, using the repo's existing npm/Vitest style where applicable.
  - [x] Keep the package isolated under `packages/schema-contract`; do not move web or iOS configuration.
  - [x] Add package README instructions for install/test/validation commands and the package's role as the canonical contract source.
- [x] Define FoodMemory v1 validation rules (AC: 1, 2)
  - [x] Add `schemas/food-memory-v1.schema.json` as the portable canonical JSON schema artifact.
  - [x] Add a TypeScript Zod 4 schema or validator source that is the implementation used by tests to validate fixtures and, if generated, to keep the JSON schema artifact in sync.
  - [x] Model common fields: `id`, `type`, `title`, `memoryDate`, `createdAt`, `updatedAt`, `photoRefs`, `note`, and `schemaVersion`.
  - [x] Model Made metadata: `dishName`, `ingredients`, `comfortLevel`, and `madeContext`.
  - [x] Model Found metadata: `restaurantName`, `locationLabel`, `coordinate`, `discoverySource`, `firstVisit`, and `foundContext`.
  - [x] Require `type` to discriminate exactly `made` or `found`; do not introduce alternate values such as `homeCooked`.
  - [x] Require IDs to be strings and date fields to be ISO 8601 strings.
  - [x] Treat optional fields consistently according to one explicit rule: omitted optional fields are preferred; use `null` only if the schema and fixtures document it deliberately.
- [x] Define photo reference contract without binary storage (AC: 2)
  - [x] Ensure `photoRefs` is an array of references, not image data.
  - [x] Each photo ref includes stable `id`, `storageKind`, local path/key, `createdAt`, and optional thumbnail key.
  - [x] Support storage kinds needed by platform stories, such as iOS local file references, web OPFS, and web IndexedDB Blob fallback.
  - [x] Add at least one test or invalid fixture proving embedded image/blob fields are rejected.
- [x] Add valid and invalid fixtures (AC: 3, 4)
  - [x] Add `fixtures/made-memory.valid.json`.
  - [x] Add `fixtures/found-memory.valid.json`.
  - [x] Add invalid fixtures under `fixtures/invalid/` for unsupported `type`, missing required shared fields, malformed date strings, missing required Made fields, missing required Found fields, and invalid/embedded photo data.
  - [x] Keep fixture field names camelCase and aligned with the architecture examples.
- [x] Add expected conformance outputs and migration notes (AC: 6)
  - [x] Add `expected/timeline-order.json` using valid fixtures or compatible example IDs to establish chronological ordering expectations for later repository/timeline work.
  - [x] Add `expected/seasonal-recap.json` as a deterministic contract seed for later recap work; keep it small and avoid implementing recap logic in this story.
  - [x] Add `migrations/v1.md` documenting `schemaVersion: 1`, current migration status, and the rule that future schema changes update fixtures and tests before platform code.
- [x] Add schema contract tests (AC: 3, 4, 5)
  - [x] Add `tests/food-memory-contract.test.ts`.
  - [x] Test valid Made and Found fixtures pass.
  - [x] Test invalid fixtures fail for the intended reason.
  - [x] Test the JSON schema artifact exists and matches the validator source if generation/sync is part of the implementation.
  - [x] Run and record the schema-contract test command.
- [x] Preserve project boundaries (AC: 1-6)
  - [x] Do not implement `FoodMemoryRepository`, `PhotoStore`, IndexedDB, SwiftData, OPFS, map/geocoding, Add Memory UI, Made gallery, Found map, Timeline UI, or seasonal recap logic.
  - [x] Do not add backend folders, API clients, authentication, cloud sync, cloud photo storage, public sharing, or server deployment placeholders.

### Pull Request

- Draft PR: https://github.com/MinnieMing412/FoodLife/pull/42
- PR branch: `codex/story-1-2-foodmemory-schema-contract`
- PR target: `main`
## Dev Notes

### Current Repository State

- Story 1.1 is complete and created the app/package shell structure. `packages/schema-contract` currently contains only `README.md`; it intentionally has no schema, fixtures, package metadata, tests, or migration notes yet. [Source: `packages/schema-contract/README.md`]
- The repo has web tooling under `apps/web` with Vite, TypeScript, Vitest, and npm scripts, but there is no root package workspace yet. If this story introduces a root workspace or package-lock, keep that change directly tied to making `packages/schema-contract` testable and document the command flow. [Source: `apps/web/package.json`; `README.md`]
- Story 1.1 established local verification patterns: run exact commands, record results, and call out sandbox/tooling limits instead of claiming unverified completion. [Source: `_bmad-output/implementation-artifacts/1-1-set-up-initial-project-from-starter-templates.md` > Dev Agent Record]

### Story Scope

- This story creates the canonical FoodMemory v1 contract and tests only. It is the foundation for later platform repositories and conformance work.
- The contract must support a dual-platform local-first product: native iOS and full web SPA, with shared behavior but platform-specific persistence. [Source: `_bmad-output/planning-artifacts/architecture.md` > Primary Technology Domain]
- Keep metadata and photo binary storage separate. `photoRefs` belongs in FoodMemory records; actual image data belongs to later platform `PhotoStore` implementations. [Source: `_bmad-output/planning-artifacts/architecture.md` > Photo Storage]
- Do not let SwiftData model types, IndexedDB records, or UI forms become the canonical schema source. The canonical source for cross-platform conformance lives in `packages/schema-contract`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Data Boundaries]

### FoodMemory v1 Contract Requirements

- Use a discriminated memory type with common fields plus type-specific metadata. [Source: `_bmad-output/planning-artifacts/architecture.md` > FoodMemory Modeling]
- Common fields: `id`, `type`, `title`, `memoryDate`, `createdAt`, `updatedAt`, `photoRefs`, `note`, `schemaVersion`. [Source: `_bmad-output/planning-artifacts/architecture.md` > FoodMemory Modeling]
- Made metadata: `dishName`, `ingredients`, `comfortLevel`, `madeContext`. [Source: `_bmad-output/planning-artifacts/architecture.md` > FoodMemory Modeling]
- Found metadata: `restaurantName`, `locationLabel`, `coordinate`, `discoverySource`, `firstVisit`, `foundContext`. [Source: `_bmad-output/planning-artifacts/architecture.md` > FoodMemory Modeling]
- Canonical JSON fixtures use camelCase, string IDs, ISO 8601 dates, and `type` values of exactly `made` or `found`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Format Patterns]
- MVP starts at `schemaVersion: 1`. Future schema changes must update fixtures and conformance tests before app code changes. [Source: `_bmad-output/planning-artifacts/architecture.md` > Migration Approach]

### Product and UX Semantics

- Made represents home cooking, comfort, ingredients, authorship, and warmth. Found represents dining-out happiness, place discovery, restaurant context, and personal exploration. The schema should preserve that semantic split without turning the app into a recipe manager or restaurant review tool. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` > Executive Summary]
- Required Made creation context is photo, dish name, ingredients, and date; optional Made context includes comfort level and notes/context. [Source: `_bmad-output/planning-artifacts/prd.md` > MVP Scope; `_bmad-output/planning-artifacts/ux-design-specification.md` > Core Interaction Model]
- Required Found creation context is photo, restaurant, location, and dining date; optional Found context includes discovery source, first-visit marker, and notes/context. [Source: `_bmad-output/planning-artifacts/prd.md` > MVP Scope; `_bmad-output/planning-artifacts/ux-design-specification.md` > Core Interaction Model]
- Food photos must not be the only way to identify a memory. Schema fixtures should include textual identifiers such as dish/restaurant name, date, ingredients, or location. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` > Accessibility & Inclusive Design]

### File Structure Requirements

Expected package structure for this story:

```text
packages/schema-contract/
  package.json
  README.md
  schemas/
    food-memory-v1.schema.json
  fixtures/
    made-memory.valid.json
    found-memory.valid.json
    invalid/
  expected/
    timeline-order.json
    seasonal-recap.json
  migrations/
    v1.md
  tests/
    food-memory-contract.test.ts
```

[Source: `_bmad-output/planning-artifacts/architecture.md` > Unified Project Structure]

### Library and Framework Requirements

- Architecture selects Zod 4 for TypeScript runtime validation and schema fixture validation. [Source: `_bmad-output/planning-artifacts/architecture.md` > Technology Stack]
- Current Zod documentation says Zod 4 is stable and supports native JSON Schema conversion with `z.toJSONSchema()`. Use stable Zod 4 APIs for validator definitions; avoid relying on experimental `z.fromJSONSchema()` unless there is a clear reason and it is documented. [Source: https://zod.dev/packages/zod; https://zod.dev/json-schema]
- Vitest is already used in the web shell and is appropriate for schema-contract tests. Keep tests command-line friendly for later CI. [Source: `apps/web/package.json`; https://vitest.dev]
- If npm workspaces are introduced, use standard npm `workspaces` behavior so local packages are linked by `npm install` from the workspace root. [Source: https://docs.npmjs.com/cli/v8/using-npm/workspaces/]

### Testing Requirements

- Follow TDD for behavior-bearing code: add failing tests first, implement the smallest passing contract, rerun tests, then refactor. [Source: `_bmad-output/planning-artifacts/architecture.md` > Testing Strategy]
- Schema-contract fixtures and conformance tests must come before platform repository/UI work. [Source: `_bmad-output/planning-artifacts/architecture.md` > Testing Strategy]
- Tests should prove valid fixtures pass and invalid fixtures fail. Avoid snapshot-only tests; assert meaningful validation behavior.
- Record the exact command and result in the Dev Agent Record before marking the story complete.

### Previous Story Intelligence

- Story 1.1 deliberately left `packages/schema-contract` as a README-only placeholder and stated that Story 1.2 owns FoodMemory schema, fixtures, and validation tests. [Source: `_bmad-output/implementation-artifacts/1-1-set-up-initial-project-from-starter-templates.md` > Story Scope]
- Story 1.1 added web dependencies under `apps/web`; do not accidentally couple the schema package to React, React Router, Tailwind, or app-shell UI code. [Source: `apps/web/package.json`; `_bmad-output/implementation-artifacts/1-1-set-up-initial-project-from-starter-templates.md` > File List]
- Recent commits show Story 1.1 merged app shells and GitHub story automation into `main`; current work should build from that structure rather than recreating app shells. [Source: `git log --oneline -5`]

### Anti-Patterns to Avoid

- Embedding image blobs directly in `FoodMemory`.
- Using different discriminator language across platforms, such as `Made` on web and `homeCooked` on iOS.
- Adding backend save endpoints, fake API clients, authentication, cloud sync, cloud photo placeholders, or server deployment files.
- Implementing repository behavior, platform persistence, map/geocoding fallback, Add Memory forms, Timeline UI, or seasonal recap generation in this story.
- Mixing omitted optional fields and `null` optional fields without an explicit schema rule.

### References

- `_bmad-output/planning-artifacts/epics.md` > Story 1.2
- `_bmad-output/planning-artifacts/prd.md` > Technical Success, Functional Requirements, Non-Functional Requirements
- `_bmad-output/planning-artifacts/architecture.md` > FoodMemory Modeling, Photo Storage, Unified Project Structure, Testing Strategy, Format Patterns
- `_bmad-output/planning-artifacts/ux-design-specification.md` > Core UX Principles, Core Interaction Model, Accessibility & Inclusive Design
- `_bmad-output/implementation-artifacts/1-1-set-up-initial-project-from-starter-templates.md` > Previous story learnings
- https://zod.dev/packages/zod
- https://zod.dev/json-schema
- https://vitest.dev
- https://docs.npmjs.com/cli/v8/using-npm/workspaces/

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Debug Log References

- `STORY_FILE="_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md" scripts/github/start-story.sh` initially failed in the restricted sandbox with `error connecting to api.github.com`; reran with approved network access and synced GitHub issue #8 / Project status successfully.
- `npm test` in `packages/schema-contract` first failed because package dependencies were not installed, then failed because the test imported the not-yet-created contract source; this confirmed the red phase before implementation.
- `npm install` in `packages/schema-contract` hung silently in the restricted sandbox; stopped the process and reran with approved network access successfully.
- `npm run generate:schema` initially failed because `tsx` could not open its temporary IPC pipe in the sandbox; reran with approved local execution and generated `schemas/food-memory-v1.schema.json`.
- `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 16' build-for-testing` first failed because Xcode required an explicit simulator OS; reran with `OS=18.6` and build-for-testing succeeded.

### Implementation Plan

- Keep the schema contract package isolated under `packages/schema-contract` with its own npm scripts and lockfile.
- Define a Zod 4 discriminated union for FoodMemory v1, export inferred TypeScript types, and generate the portable JSON Schema artifact from the Zod source.
- Use fixture-driven Vitest coverage for valid Made/Found memories, required-field failures, malformed dates, unsupported discriminator values, embedded photo data rejection, optional-field null rejection, and JSON Schema sync.
- Add small expected conformance outputs for timeline ordering and seasonal recap seeds without implementing repository, storage, UI, map, timeline, or recap logic.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Created an isolated `@foodlife/schema-contract` package with npm scripts for `test`, `validate`, and JSON Schema generation.
- Added the canonical FoodMemory v1 Zod validator with common fields, Made metadata, Found metadata, strict `made` / `found` discrimination, string IDs, ISO 8601 date-time validation, `schemaVersion: 1`, and omitted-optional-field semantics.
- Modeled `photoRefs` as local references with `iosLocalFile`, `webOpfs`, and `webIndexedDbBlob` storage kinds, and rejected embedded image/blob fields.
- Added valid Made and Found fixtures plus invalid fixtures for unsupported type, missing shared fields, malformed date strings, missing Made fields, missing Found fields, and embedded photo data.
- Added generated `schemas/food-memory-v1.schema.json`, expected timeline/seasonal conformance seeds, and `migrations/v1.md`.
- Added schema contract tests and verified `npm test` and `npm run validate` pass in `packages/schema-contract`.
- Verified existing web regression commands: `npm run test`, `npm run lint`, and `npm run build` from `apps/web`.
- Verified existing iOS build-for-testing with `xcodebuild -project apps/ios/FoodLife.xcodeproj -scheme FoodLife -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' build-for-testing`.

### File List

- `_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `packages/schema-contract/README.md`
- `packages/schema-contract/package-lock.json`
- `packages/schema-contract/package.json`
- `packages/schema-contract/tsconfig.json`
- `packages/schema-contract/src/food-memory-v1.ts`
- `packages/schema-contract/src/generate-json-schema.ts`
- `packages/schema-contract/schemas/food-memory-v1.schema.json`
- `packages/schema-contract/fixtures/made-memory.valid.json`
- `packages/schema-contract/fixtures/found-memory.valid.json`
- `packages/schema-contract/fixtures/invalid/unsupported-type.invalid.json`
- `packages/schema-contract/fixtures/invalid/missing-required-shared.invalid.json`
- `packages/schema-contract/fixtures/invalid/malformed-date.invalid.json`
- `packages/schema-contract/fixtures/invalid/missing-made-field.invalid.json`
- `packages/schema-contract/fixtures/invalid/missing-found-field.invalid.json`
- `packages/schema-contract/fixtures/invalid/embedded-photo-data.invalid.json`
- `packages/schema-contract/expected/timeline-order.json`
- `packages/schema-contract/expected/seasonal-recap.json`
- `packages/schema-contract/migrations/v1.md`

### Change Log

- 2026-05-13: Implemented FoodMemory v1 schema contract package, fixtures, conformance outputs, migration notes, and validation tests.
