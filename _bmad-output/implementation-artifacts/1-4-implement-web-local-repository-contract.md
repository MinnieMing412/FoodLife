# Story 1.4: Implement Web Local Repository Contract

Status: done
<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a FoodLife user,
I want the web app to preserve local memory records across browser sessions,
so that my food archive remains available without an account or cloud sync.

## Acceptance Criteria

1. Given FoodMemory v1 fixtures exist, when the web local repository is implemented, then it exposes the agreed repository methods for create, update, delete, get, and list behavior needed by future stories.
2. The repository persists memory metadata locally with IndexedDB-compatible storage.
3. Persisted records map to and from the canonical FoodMemory v1 contract.
4. Repository conformance tests cover Made and Found records, local retrieval after restart simulation, and no network dependency.
5. No UI feature depends directly on IndexedDB implementation details.

## Tasks / Subtasks

- [x] Define the web domain and service contract before persistence implementation (AC: 1, 3, 5)
  - [x] Add `apps/web/src/domain/food-memory.ts` as the web-facing type boundary that reuses or mirrors the canonical FoodMemory v1 shape without making UI code import persistence internals.
  - [x] Add `apps/web/src/services/food-memory-repository.ts` with the `FoodMemoryRepository` interface and method names required by architecture: `createMemory`, `updateMemory`, `deleteMemory`, `getMemory`, and `listTimeline`.
  - [x] Include stable domain error codes or typed failures for `validation_failed`, `storage_unavailable`, `quota_exceeded`, and `migration_unsupported` at the service boundary.
  - [x] Keep repository signatures serializable and backend-ready; do not expose IndexedDB, Dexie, `IDBDatabase`, transactions, object stores, or browser-specific record types through the service interface.
- [x] Implement IndexedDB-compatible persistence behind the service boundary (AC: 1, 2, 3, 5)
  - [x] Add persistence files under `apps/web/src/persistence/indexed-db/`, using kebab-case filenames.
  - [x] Create a `memories` object store keyed by string `id` and any indexes needed for `type`, `memoryDate`, and `updatedAt`.
  - [x] Validate every record written to and read from persistence against the canonical FoodMemory v1 schema.
  - [x] Persist memory metadata and `photoRefs` only; do not store photo blobs or implement `PhotoStore` in this story.
  - [x] Implement deletion and missing-record behavior explicitly for future UI flows.
- [x] Add repository conformance tests before or alongside implementation (AC: 1, 2, 3, 4)
  - [x] Add Vitest tests colocated with the repository implementation or conformance runner under `apps/web/src/persistence/`.
  - [x] Use `packages/schema-contract/fixtures/made-memory.valid.json` and `packages/schema-contract/fixtures/found-memory.valid.json` as canonical seeds.
  - [x] Assert create/get/update/delete behavior for both Made and Found memories.
  - [x] Assert `listTimeline` returns records sorted by `memoryDate` descending and aligns with `packages/schema-contract/expected/timeline-order.json`.
  - [x] Simulate an app/browser restart by constructing a new repository instance against the same database name and verifying previously saved records are still retrievable.
  - [x] Prove the repository does not call `fetch`, XHR, or any network client during persistence operations.
- [x] Preserve web UI boundaries and existing app shell behavior (AC: 5)
  - [x] Do not wire placeholder routes or React components directly to IndexedDB in this story.
  - [x] Do not build Add Memory, Made gallery, Found map, Timeline UI, Home recap, Detail/Edit UI, or photo storage flows.
  - [x] Keep existing `App.tsx` route placeholder tests passing.
- [x] Run and record verification (AC: 1-5)
  - [x] Run `npm run test` from `apps/web` and record the passing result.
  - [x] Run `npm run lint` from `apps/web` and record the passing result.
  - [x] Run `npm run build` from `apps/web` and record the passing result.
  - [x] Run `npm test` and `npm run validate` from `packages/schema-contract` if schema-contract imports or fixtures are touched.
  - [x] If dependencies are added, record why they are required and confirm the relevant lockfile changes are intentional.

## Dev Notes

### Current Repository State

- `main` was fast-forwarded to `origin/main` at `5da3831` before this story was created. That includes Story 1.3 and the current baseline CI workflow. [Source: `git log --oneline -8`]
- The web app currently has only shell-level React files under `apps/web/src`: `App.tsx`, `App.test.tsx`, `main.tsx`, `index.css`, and `test-setup.ts`. There is no existing `domain`, `services`, `persistence`, or `features` folder yet. [Source: `find apps/web/src -maxdepth 3 -type f`]
- `apps/web/package.json` currently includes React, React Router, Vite, TypeScript, Vitest, Testing Library, Tailwind, and ESLint. It does not currently include Dexie, fake-indexeddb, or other IndexedDB test helpers. [Source: `apps/web/package.json`]
- `packages/schema-contract` already contains the canonical FoodMemory v1 Zod schema, generated JSON Schema, valid Made/Found fixtures, invalid fixtures, timeline expected output, seasonal recap expected output, migration notes, and tests. [Source: `packages/schema-contract/src/food-memory-v1.ts`; `packages/schema-contract/fixtures/*.json`; `packages/schema-contract/expected/*.json`]

### Story Scope

- This story creates the web repository contract and local metadata persistence boundary only.
- It should not implement photo binary storage. `photoRefs` are metadata references on FoodMemory records; actual photo persistence belongs to Story 1.5.
- It should not implement UI feature flows. Future screens must call `FoodMemoryRepository` or hooks built on top of it; they must not call IndexedDB directly.
- It may add a small IndexedDB wrapper dependency if it materially reduces transaction/versioning complexity. Architecture explicitly allows Dexie or a similarly small wrapper. If adding a dependency, keep it web-local under `apps/web` and update `apps/web/package-lock.json`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Important Decisions]

### Repository Contract Requirements

- Service interface name: `FoodMemoryRepository`. [Source: `_bmad-output/planning-artifacts/architecture.md` > API Naming Conventions]
- Required method names for this story: `createMemory`, `updateMemory`, `deleteMemory`, `getMemory`, and `listTimeline`. [Source: `_bmad-output/planning-artifacts/epics.md` > Story 1.4; `_bmad-output/planning-artifacts/architecture.md` > API Naming Conventions]
- Return and input types should be serializable FoodMemory v1 domain types. Do not expose Dexie, `IDBDatabase`, object stores, native events, or transaction objects outside `apps/web/src/persistence/indexed-db/`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Backend-Ready Boundary]
- Domain errors should use stable codes. For this repository story, at minimum handle validation and storage/migration failures with existing architecture codes: `validation_failed`, `storage_unavailable`, `quota_exceeded`, `migration_unsupported`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Error Handling Patterns]
- `listTimeline` must sort by `memoryDate` descending, matching `packages/schema-contract/expected/timeline-order.json`. [Source: `packages/schema-contract/expected/timeline-order.json`; `_bmad-output/planning-artifacts/architecture.md` > Requirements to Structure Mapping]

### Persistence Requirements

- Web metadata store is IndexedDB. [Source: `_bmad-output/planning-artifacts/architecture.md` > Data Architecture]
- IndexedDB store names use plural lower camel names. Use `memories` for memory records; do not add `photos` or `schemaMigrations` unless needed for this story's migration/versioning behavior. [Source: `_bmad-output/planning-artifacts/architecture.md` > Database Naming Conventions]
- Canonical fixture JSON uses camelCase, string IDs, ISO 8601 dates, `schemaVersion`, and `type` discriminator values of exactly `made` or `found`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Format Patterns]
- Persisted records must validate against `foodMemoryV1Schema` from `packages/schema-contract/src/food-memory-v1.ts` or an equivalent import path exposed by that package. Do not fork the schema into a separate web-only truth.
- Optional fields in v1 are omitted when absent; `null` is not valid. [Source: `packages/schema-contract/README.md`]

### File Structure Guidance

Expected new or updated web structure for this story:

```text
apps/web/src/
  domain/
    food-memory.ts
    food-life-error.ts
  services/
    food-memory-repository.ts
  persistence/
    indexed-db/
      food-life-db.ts
      indexed-db-food-memory-repository.ts
      indexed-db-food-memory-repository.test.ts
    conformance/
      food-memory-repository-conformance.test.ts
```

This is guidance, not a mandate to create unnecessary files. Prefer the smallest structure that keeps domain, service interface, persistence implementation, and tests separated.

### Testing Requirements

- Follow TDD for repository behavior: write the failing repository/conformance tests first, run them, implement the smallest passing repository, then refactor. [Source: `_bmad-output/planning-artifacts/architecture.md` > Test-Driven Development Pattern]
- Web repository tests must use Vitest. [Source: `_bmad-output/planning-artifacts/architecture.md` > Platform test expectations]
- Tests must cover Made and Found fixtures, create/get/update/delete, `listTimeline`, restart persistence simulation, validation rejection of invalid records, and no network dependency.
- For IndexedDB tests in Node/Vitest, a focused test helper such as `fake-indexeddb` is acceptable if added as a dev dependency and documented in the Dev Agent Record.
- If using Dexie, prefer a repository factory that accepts a database name or database instance for tests, so restart simulation can create a second repository instance against the same logical database.

### Latest Technical Information

- MDN documents IndexedDB as a browser API for client-side storage using databases, object stores, indexes, and transactions; transactions must declare store scope and read/write mode. [Source: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API]
- MDN's IndexedDB usage guide notes that multiple overlapping `readonly` transactions can run concurrently, while `readwrite` transaction behavior is constrained for object-store writes. Design repository operations as explicit async storage calls rather than synchronous local state. [Source: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Using_IndexedDB]
- Dexie is an official IndexedDB wrapper with TypeScript support and versioned stores. Use it only if it keeps the implementation smaller and clearer than raw IndexedDB; do not expose Dexie types at the service boundary. [Source: https://dexie.org/docs/Dexie/Dexie; https://dexie.org/docs/API-Reference]
- `fake-indexeddb` is a Node test implementation of IndexedDB commonly used for IndexedDB tests. If added, keep it as a dev dependency in `apps/web`. [Source: https://www.npmjs.com/package/fake-indexeddb]

### Previous Story Intelligence

- Story 1.3 added `dev-*` to CI branch filters and confirmed both `Web and Schema Contract` and `iOS Build and Unit Tests` passed on PR #44. Keep this branch naming convention for the implementation branch. [Source: `_bmad-output/implementation-artifacts/1-3-establish-baseline-ci-and-verification-workflow.md` > Completion Notes List]
- Story 1.3 verified the web command set: `npm run test`, `npm run lint`, and `npm run build` from `apps/web`. Use these commands before marking this story complete. [Source: `_bmad-output/implementation-artifacts/1-3-establish-baseline-ci-and-verification-workflow.md` > Completion Notes List]
- Story 1.2 established `packages/schema-contract` as the canonical schema source with strict validation and omitted-optional-field semantics. Do not duplicate or weaken that contract in web persistence. [Source: `_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md` > Completion Notes List]

### Anti-Patterns to Avoid

- Letting React components import IndexedDB/Dexie directly.
- Creating a backend API, fake API client, auth provider, cloud sync placeholder, server deployment file, or remote repository implementation.
- Storing image blobs in FoodMemory records or building photo storage in this story.
- Creating a separate web-only FoodMemory schema that can diverge from `packages/schema-contract`.
- Treating `localStorage` as equivalent to IndexedDB-compatible persistence for this story.
- Passing tests only through manual browser clicking; repository behavior must be covered by automated Vitest tests.

### References

- `_bmad-output/planning-artifacts/epics.md` > Story 1.4
- `_bmad-output/planning-artifacts/architecture.md` > Data Architecture
- `_bmad-output/planning-artifacts/architecture.md` > Implementation Patterns & Consistency Rules
- `_bmad-output/planning-artifacts/architecture.md` > Project Structure & Boundaries
- `_bmad-output/planning-artifacts/prd.md` > FR27, FR28, FR37, FR40, FR41, FR42, FR43, NFR12, NFR23
- `_bmad-output/implementation-artifacts/1-2-define-foodmemory-v1-schema-contract.md`
- `_bmad-output/implementation-artifacts/1-3-establish-baseline-ci-and-verification-workflow.md`
- `packages/schema-contract/src/food-memory-v1.ts`
- `packages/schema-contract/fixtures/made-memory.valid.json`
- `packages/schema-contract/fixtures/found-memory.valid.json`
- `packages/schema-contract/expected/timeline-order.json`
- `apps/web/package.json`
- https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
- https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Using_IndexedDB
- https://dexie.org/docs/Dexie/Dexie
- https://dexie.org/docs/API-Reference
- https://www.npmjs.com/package/fake-indexeddb

## Dev Agent Record

### Agent Model Used

GPT-5

### Debug Log References

- 2026-05-15: Red test run confirmed repository module missing before implementation (`npm run test` from `apps/web` failed on unresolved repository import).
- 2026-05-15: `npm run test` from `apps/web` passed with 2 files and 8 tests after review follow-up.
- 2026-05-15: `npm run lint` from `apps/web` passed.
- 2026-05-15: `npm run build` from `apps/web` passed.
- 2026-05-15: `npm test` from `packages/schema-contract` passed with 1 file and 9 tests.
- 2026-05-15: `npm run validate` from `packages/schema-contract` passed with 1 file and 9 tests.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Added the web FoodMemory domain boundary and serializable `FoodMemoryRepository` service interface without exposing IndexedDB types to UI-facing code.
- Implemented raw IndexedDB-backed metadata persistence with a `memories` object store keyed by `id` and indexes for `type`, `memoryDate`, and `updatedAt`.
- Validated all repository writes and reads through the canonical `@foodlife/schema-contract` FoodMemory v1 schema.
- Added Vitest conformance coverage for Made and Found fixtures, create/get/update/delete, timeline ordering, restart persistence, validation errors, and no network API usage.
- Added `@foodlife/schema-contract` as a local web dependency and `fake-indexeddb` as a web-only dev dependency for Node/Vitest IndexedDB coverage; lockfile changes are intentional.
- Review follow-up: fixed timeline sorting to compare ISO instants via `Date.parse` instead of lexicographic text, with regression coverage for differing timezone offsets.

### File List

- `apps/web/package-lock.json`
- `apps/web/package.json`
- `apps/web/src/domain/food-life-error.ts`
- `apps/web/src/domain/food-memory.ts`
- `apps/web/src/persistence/indexed-db/food-life-db.ts`
- `apps/web/src/persistence/indexed-db/indexed-db-food-memory-repository.test.ts`
- `apps/web/src/persistence/indexed-db/indexed-db-food-memory-repository.ts`
- `apps/web/src/services/food-memory-repository.ts`

### Change Log

- 2026-05-15: Implemented web local repository contract and IndexedDB persistence boundary for Story 1.4.
