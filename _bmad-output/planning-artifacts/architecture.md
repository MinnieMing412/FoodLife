---
stepsCompleted:
  - step-01-init
  - step-02-context
  - step-03-starter
  - step-04-decisions
  - step-05-patterns
  - step-06-structure
  - step-07-validation
  - step-08-complete
inputDocuments:
  - /Users/yimingli/workspace/my_projects/FoodLife/_bmad-output/planning-artifacts/prd.md
  - /Users/yimingli/workspace/my_projects/FoodLife/_bmad-output/planning-artifacts/prd-validation-report.md
  - /Users/yimingli/workspace/my_projects/FoodLife/_bmad-output/planning-artifacts/ux-design-specification.md
workflowType: 'architecture'
project_name: 'FoodLife'
user_name: 'yiming'
date: '2026-05-03'
lastStep: 8
status: 'complete'
completedAt: '2026-05-03'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
FoodLife v1 is a greenfield cross-platform product with a native iOS app and full web SPA. The core architecture must support a shared FoodMemory model across both platforms while allowing platform-specific implementations for local storage, photo capture, photo selection, map display, and accessibility behavior.

The functional surface is organized around six product areas: type-first Add Memory, Made memories, Found memories, local memory management, Home seasonal reflection, and Timeline. The most important architectural requirement is that Made and Found share a common underlying record model without forcing identical user experiences. Both platforms must support create, edit, browse, detail, local photo retrieval, chronological sorting, seasonal grouping, and location retrieval.

**Non-Functional Requirements:**
Architecture is shaped by local-first reliability, cross-platform schema consistency, photo association integrity, graceful map/geocoding failure behavior, and future cloud readiness. The app must support local archives of at least 2,000 memories, render already-stored local navigation within 500 ms, generate seasonal recaps within 1 second or asynchronously, and preserve saved records across app/browser restarts.

Privacy constraints are strong: MVP excludes accounts, authentication, cloud sync, public sharing, tracking, ads, background location, notifications, payments, and social visibility. iOS permissions are limited to camera, photo library, and location.

**Scale & Complexity:**

- Primary domain: local-first cross-platform consumer app
- Complexity level: medium-low product complexity, medium architecture risk due to dual platform and photo/location storage
- Estimated architectural components: shared schema contract, storage abstraction, iOS local persistence, web local persistence, photo reference/storage layer, map/location service boundary, recap/timeline query layer, UI state/navigation layer, schema conformance tests

### Technical Constraints & Dependencies

FoodLife needs platform-specific implementations behind shared behavior contracts. iOS should use native camera/photo library/location/map capabilities. Web must handle browser storage and local photo constraints carefully enough to be a complete archive, while acknowledging browser limits.

Map tiles and geocoding may depend on external services, but Found memory saving must not depend on those services being available. Location metadata should remain manually preservable and browsable through fallback list/preview/detail patterns.

Photo references must be modeled separately from memory metadata so local photo storage can later move to cloud photo storage without redefining the core FoodMemory schema.

### Cross-Cutting Concerns Identified

- Shared FoodMemory schema and schema conformance across iOS and web
- Local-first persistence and restart durability
- Photo storage, photo reference integrity, and edit preservation
- Made/Found type-specific metadata without divergent data models
- Timeline sorting and seasonal recap generation from local records
- Map/geocoding abstraction with offline and failed-service fallback
- Privacy-preserving permission boundaries
- Accessibility: WCAG 2.2 AA on web and platform accessibility on iOS
- Responsive behavior across mobile, tablet, desktop, and wide desktop
- Future migration path to cloud sync and cloud photo storage

## Starter Template Evaluation

### Primary Technology Domain

FoodLife is a dual-platform local-first app: native iOS plus web SPA. The architecture should use separate app starters inside one repository, with shared contracts and conformance tests rather than forcing one cross-platform runtime.

### Starter Options Considered

**Native iOS SwiftUI Xcode App Template**
Recommended for the iOS app because the PRD explicitly calls for a Swift-first native iOS app with camera, photo library, location, map behavior, Dynamic Type, VoiceOver, and App Store privacy alignment. Apple's current Xcode flow supports creating an iOS app from a template, choosing Swift as the language, SwiftUI as the interface, and including unit/UI tests.

**Vite React TypeScript**
Recommended for the web app because the PRD calls for a browser SPA, not SSR, public SEO pages, or a backend-driven full-stack app. Vite currently provides an official `react-ts` template, fast local development, optimized production builds, TypeScript support, and straightforward static deployment.

**React Router**
Use React Router in Declarative or Data mode for web navigation. Framework mode is not necessary for MVP because FoodLife does not need SSR, server route modules, or public SEO behavior. Data mode may be useful if route-level loading boundaries help local IndexedDB/photo query flows.

**Tailwind CSS via Vite Plugin**
Recommended as the web styling foundation because the UX spec requires responsive layouts, design tokens, type-specific visual variants, stable spacing, and fast iteration. Tailwind v4's Vite plugin is current and keeps styling zero-runtime.

**Vitest**
Recommended for web unit and schema conformance tests because it is Vite-native, TypeScript/JSX-aware, and reuses Vite configuration. Schema and local storage behavior should have deterministic tests before UI polish.

### Selected Starter: Native SwiftUI App + Vite React TypeScript Web App

**Rationale for Selection:**
This preserves the PRD's platform intent: iOS should be genuinely native, while web should be a full SPA. A single shared runtime such as React Native or Flutter would reduce duplication but would conflict with the Swift-first iOS requirement and native iOS capability expectations. A full-stack web starter such as Next.js is heavier than needed because MVP excludes accounts, server-rendered public pages, cloud sync, and backend services.

**Initialization Commands:**

```bash
npm create vite@latest apps/web -- --template react-ts
```

For iOS, initialize with Xcode:

```text
File > New > Project > iOS > App
Product Name: FoodLife
Interface: SwiftUI
Language: Swift
Include Unit Tests: Yes
Include UI Tests: Yes
Location: apps/ios
```

**Architectural Decisions Provided by Starter:**

**Language & Runtime:**
- iOS: Swift + SwiftUI
- Web: TypeScript + React
- Shared contract: schema fixtures and conformance cases maintained in the repo, with platform-specific model implementations

**Styling Solution:**
- iOS: SwiftUI-native styling mapped to FoodLife design tokens
- Web: Tailwind CSS via `@tailwindcss/vite`, with FoodLife tokens expressed as CSS/theme variables

**Build Tooling:**
- iOS: Xcode build system
- Web: Vite dev server and production build
- Repository: app folders under `apps/ios` and `apps/web`, plus shared contract/test assets under a shared package or top-level `packages/schema-contract`

**Testing Framework:**
- iOS: XCTest and UI tests from Xcode
- Web: Vitest for unit tests, schema conformance, local storage behavior, recap/timeline pure functions, and component tests where useful

**Code Organization:**
- `apps/ios`: native iOS app, SwiftUI views, local persistence, photo/location/map adapters
- `apps/web`: React SPA, route/view components, IndexedDB/photo handling, map fallback UI
- `packages/schema-contract`: canonical FoodMemory examples, validation rules, migration notes, and conformance fixtures used by both platforms

**Development Experience:**
- Web starts with Vite HMR and TypeScript
- iOS starts with SwiftUI previews and native simulator/device workflows
- First implementation story should initialize both app shells and the shared schema contract before feature work

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Use platform-native local persistence behind a shared repository contract.
- Store memory metadata separately from photo binaries/references.
- Define FoodMemory through shared conformance fixtures, not a single generated cross-platform model.
- Keep MVP authentication, cloud sync, backend APIs, public sharing, and server infrastructure out of scope.
- Implement map/geocoding as replaceable platform adapters with manual location fallback.

**Important Decisions (Shape Architecture):**
- Use SwiftData for iOS metadata persistence unless implementation spikes reveal migration or query limitations.
- Use IndexedDB for web metadata persistence, with Dexie or a similarly small wrapper to simplify schema upgrades and transactions.
- Use OPFS for web photo/blob storage where available, with IndexedDB Blob fallback.
- Use Zod 4 for TypeScript runtime validation and schema fixture validation.
- Use React Router in Data mode if route-level loading states help local data reads; otherwise Declarative mode is sufficient.
- Use React local state/context first; avoid a global state library until repeated cross-route state pressure appears.

**Deferred Decisions (Post-MVP):**
- Cloud sync provider and account/auth model.
- Cloud photo storage provider.
- Public sharing, social visibility, analytics, push notifications, and backend APIs.
- Cross-device conflict resolution.
- Advanced map clustering and rich geocoding provider behavior.

### Data Architecture

**Decision: Platform-native metadata stores behind a shared storage contract.**

- iOS metadata store: SwiftData.
- Web metadata store: IndexedDB.
- Shared abstraction: `FoodMemoryRepository` behavior contract covering create, update, delete, get, list, timeline sorting, seasonal grouping, location retrieval, and photo reference lookup.
- Shared conformance: canonical JSON fixtures and expected query outputs in `packages/schema-contract`.

**Rationale:**
FoodLife is local-first and dual-platform. A single database runtime would add complexity without improving the MVP. SwiftData aligns with SwiftUI and modern iOS persistence. IndexedDB is the browser-native option for significant structured local data. The shared contract keeps behavior aligned without forcing identical implementation internals.

**FoodMemory Modeling:**
Use a discriminated memory type with common fields and type-specific metadata.

Common fields:
- `id`
- `type`
- `title`
- `memoryDate`
- `createdAt`
- `updatedAt`
- `photoRefs`
- `note`
- `schemaVersion`

Made metadata:
- `dishName`
- `ingredients`
- `comfortLevel`
- `madeContext`

Found metadata:
- `restaurantName`
- `locationLabel`
- `coordinate`
- `discoverySource`
- `firstVisit`
- `foundContext`

**Photo Storage:**
Photo references are separate from memory metadata.

- iOS: app-local file storage for image files, referenced by stable photo IDs or relative file paths stored in SwiftData.
- Web: OPFS for photo blobs where available; IndexedDB Blob fallback where OPFS is unavailable.
- Memory records never embed full image binaries.

**Migration Approach:**
Use explicit `schemaVersion` on records and migration notes in `packages/schema-contract`. MVP starts at version `1`. Any schema change must update fixtures and conformance tests before app code changes.

### Authentication & Security

**Decision: No authentication or authorization in MVP.**

FoodLife v1 is single-user and local-first. There are no accounts, remote APIs, sessions, roles, public URLs, or shared records.

**Security posture:**
- Store data locally by default.
- Request only camera, photo library, and location permissions on iOS.
- Do not request background location, contacts, tracking, notifications, health, payment, or advertising permissions.
- Do not expose memories publicly.
- Treat browser storage as origin-local and user-clearable.
- Do not promise end-to-end encryption or secure backup in MVP unless a later PRD revision adds it.

### API & Communication Patterns

**Decision: No backend API for MVP.**

All create, edit, browse, timeline, seasonal recap, and map fallback workflows operate against local repositories.

**Internal API pattern:**
Use platform-local service interfaces rather than network APIs:

- `FoodMemoryRepository`
- `PhotoStore`
- `LocationService`
- `MapDisplayAdapter`
- `SeasonalRecapService`
- `SchemaConformanceRunner`

**Error handling:**
Use typed domain errors for predictable failures:

- validation failure
- photo save failure
- photo missing
- storage unavailable
- quota exceeded
- location unavailable
- map service unavailable
- migration unsupported

Map/geocoding failures must not block saving a Found memory with manual restaurant and location metadata.

### Frontend Architecture

**iOS:**
- SwiftUI views organized by product area: Home, Made, Found, Timeline, Add Memory, Detail/Edit.
- View models or observable state objects mediate between SwiftUI and repositories where view logic would otherwise become heavy.
- Native adapters handle camera, photo library, location, and maps.
- SwiftData model objects should not leak into all UI surfaces; map them to domain models or lightweight view state where useful.

**Web:**
- React + TypeScript SPA using Vite.
- React Router for Home, Made, Found, Timeline, Add Memory, and Detail/Edit routes.
- Tailwind CSS via Vite plugin for responsive styling and FoodLife design tokens.
- React state and context for UI state; repository hooks for local data reads/writes.
- Avoid global state libraries unless needed after implementation pressure is visible.
- Vitest for unit tests, conformance tests, local repository tests, and pure recap/timeline logic.

**Performance:**
- Timeline and gallery queries must support at least 2,000 memories.
- Seasonal recap should be pure, deterministic, and async-capable.
- Image loading should use thumbnails or derived display assets where implementation requires it.
- Local navigation should render already-stored data within the PRD's 500 ms target.

### Infrastructure & Deployment

**Decision: Minimal infrastructure for MVP.**

- iOS distribution: Xcode build and App Store/TestFlight path when ready.
- Web deployment: static SPA hosting.
- No backend service, database server, authentication provider, object storage, or server-side rendering in MVP.

**Repository structure:**
- `apps/ios`
- `apps/web`
- `packages/schema-contract`
- `docs` or `_bmad-output` for planning artifacts

**CI/CD direction:**
- Web CI: install, typecheck, test, build.
- iOS CI: build and test when CI environment supports Xcode.
- Schema contract CI: validate fixtures and expected conformance outputs before app implementation proceeds.

### Decision Impact Analysis

**Implementation Sequence:**
1. Initialize repository app structure.
2. Create schema contract package with FoodMemory v1 fixtures.
3. Create iOS SwiftData metadata model and photo reference model.
4. Create web IndexedDB metadata store and photo store abstraction.
5. Implement shared repository behavior tests on web and matching XCTest cases on iOS.
6. Build Add Memory flow after local create/photo save contracts pass.
7. Build Made, Found, Timeline, Home, and Detail/Edit on top of repository interfaces.

**Cross-Component Dependencies:**
- Add Memory depends on `FoodMemoryRepository`, `PhotoStore`, and validation.
- Made gallery depends on type filtering, local photo retrieval, and stable photo references.
- Found map depends on location metadata and map fallback behavior.
- Timeline depends on chronological query behavior.
- Home recap depends on seasonal grouping and local query performance.
- Future cloud sync depends on schema versioning, photo references, and repository boundaries staying clean.

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:**
AI agents could diverge on schema naming, date formats, repository boundaries, photo reference handling, route naming, file placement, error shapes, loading states, test locations, and whether tests are written before behavior. These rules keep iOS, web, and schema-contract work compatible.

### Naming Patterns

**Database Naming Conventions:**
- Use camelCase field names in canonical JSON fixtures: `memoryDate`, `createdAt`, `photoRefs`.
- Use platform-native persistence naming internally only if mapped cleanly to the canonical contract.
- IndexedDB stores use plural lower camel names: `memories`, `photos`, `schemaMigrations`.
- SwiftData model types use PascalCase: `FoodMemoryRecord`, `PhotoReferenceRecord`.

**API Naming Conventions:**
- MVP has no network API.
- Internal service interfaces use noun-based names: `FoodMemoryRepository`, `PhotoStore`, `LocationService`.
- Repository methods use verb-first names: `createMemory`, `updateMemory`, `deleteMemory`, `getMemory`, `listTimeline`.

**Code Naming Conventions:**
- TypeScript files use kebab-case: `food-memory-repository.ts`, `seasonal-recap-service.ts`.
- React components use PascalCase files: `MemoryCard.tsx`, `AddMemoryFlow.tsx`.
- Swift files use PascalCase: `FoodMemoryRepository.swift`, `MadeGalleryView.swift`.
- Domain model names must include the product language: `MadeMemory`, `FoundMemory`, `FoodMemory`.

### Structure Patterns

**Project Organization:**
- `apps/ios` contains only native iOS app code.
- `apps/web` contains only web app code.
- `packages/schema-contract` contains canonical schema fixtures, expected query outputs, and migration notes.
- Product areas are organized consistently: Home, Made, Found, Timeline, Add Memory, Detail/Edit.

**Test Placement:**
- Web tests colocate with implementation for feature logic: `*.test.ts` or `*.test.tsx`.
- Schema contract tests live under `packages/schema-contract`.
- iOS unit/UI tests remain in Xcode test targets.
- Any repository implementation must include conformance tests before UI depends on it.

### Format Patterns

**Data Exchange Formats:**
- Canonical fixture JSON uses camelCase.
- Dates use ISO 8601 strings.
- IDs are strings.
- `type` is the discriminator and must be either `made` or `found`.
- Optional missing fields should be omitted or `null` consistently per schema-contract rules, not mixed ad hoc.

**Photo Reference Format:**
- Memory records store `photoRefs`, not photo blobs.
- A photo ref must include stable ID, storage kind, local path/key, created date, and optional thumbnail key.
- UI code must not assume photo files live beside metadata.

### Communication Patterns

**State Management Patterns:**
- Prefer local view state for forms and transient UI.
- Use repository hooks/services for persisted data.
- Do not introduce a global state library without an architecture update.
- Save flows should stage user edits before committing, especially on iOS where persistence frameworks may autosave managed objects.

**Event Patterns:**
- MVP does not need a global event bus.
- Use explicit service calls and route/navigation state.
- If local events are introduced later, use lower dot names: `memory.created`, `photo.saved`, `map.unavailable`.

### Process Patterns

**Test-Driven Development Pattern:**
All implementation agents must use TDD for behavior-bearing code.

Required cycle:
1. Write or update a failing test that describes the intended behavior.
2. Run the relevant test command and confirm the failure is meaningful.
3. Implement the smallest code change that makes the test pass.
4. Run the relevant test command again and confirm it passes.
5. Refactor only after tests are green.

TDD applies to schema contract validation, repository behavior, photo reference and storage behavior, timeline sorting, seasonal recap generation, map/geocoding fallback behavior, form validation and save/update flows, domain error mapping, and accessibility-critical component behavior where testable.

Testing priority:
- Start with schema-contract fixtures and repository conformance tests before UI implementation.
- Pure domain logic must have unit tests before being used by views.
- Storage adapters must have integration-style tests or platform test equivalents before feature screens depend on them.
- UI work should include focused tests for critical behavior, not snapshot-only coverage.

Platform test expectations:
- Web: Vitest for schema, repository, services, hooks, and component behavior.
- iOS: XCTest for schema conformance, repository behavior, recap/timeline logic, and storage/photo reference behavior.
- UI automation is required for critical Add Memory and edit flows once the app shell exists.

Agent handoff rule:
- An implementation story is not complete unless the agent reports the failing test added first, implementation completed, relevant tests passing, and any untested behavior explicitly called out.

**Error Handling Patterns:**
- Domain errors use stable codes: `validation_failed`, `photo_save_failed`, `photo_missing`, `storage_unavailable`, `quota_exceeded`, `location_unavailable`, `map_unavailable`, `migration_unsupported`.
- User-facing messages are mapped at the UI boundary.
- Map/geocoding errors must not block Found memory save if manual location metadata exists.

**Loading State Patterns:**
- Loading state names use `isLoading`, `isSaving`, `isDeleting`, `isPhotoLoading`.
- Loading states should be local to the component or route unless multiple product areas need the same state.
- Photo grids, timeline rows, and recap modules reserve layout space while loading.

### Enforcement Guidelines

**All AI Agents MUST:**
- Update schema-contract fixtures before changing FoodMemory shape.
- Keep metadata and photo binary storage separate.
- Preserve Made/Found discriminator semantics across iOS and web.
- Follow TDD for behavior-bearing code: failing test first, minimal implementation, green tests, then refactor.
- Add or update repository conformance tests for storage behavior changes.
- Do not mark implementation complete without reporting the relevant test command and result.
- Keep MVP backend/auth/cloud decisions out unless the PRD and architecture are revised.

**Pattern Enforcement:**
- Schema changes require fixture updates and conformance tests.
- New service interfaces must be named and placed consistently.
- Any deviation from these patterns must be documented in this architecture file before implementation continues.

### Pattern Examples

**Good Examples:**
- `memoryDate: "2026-05-03T12:00:00-07:00"`
- `type: "made"`
- `photoRefs: [{ "id": "photo_123", "storageKind": "opfs", "storageKey": "photos/photo_123.jpg" }]`
- `FoodMemoryRepository.createMemory(input)`
- `apps/web/src/features/made/MadeGallery.tsx`

**Anti-Patterns:**
- Embedding image blobs directly in `FoodMemory`.
- Using `Made` on web and `homeCooked` on iOS for the same discriminator.
- Adding a backend save endpoint during MVP.
- Letting SwiftData model objects define the canonical schema by accident.
- Handling map failure by blocking Found memory creation.
- Building storage, schema, recap, timeline, or save-flow behavior before writing tests.
- Treating manual clicking as a substitute for repository or schema conformance tests.

## Project Structure & Boundaries

### Complete Project Directory Structure

```text
FoodLife/
├── README.md
├── package.json
├── package-lock.json
├── .gitignore
├── .github/
│   └── workflows/
│       ├── web-ci.yml
│       └── schema-contract-ci.yml
├── apps/
│   ├── ios/
│   │   ├── FoodLife.xcodeproj/
│   │   ├── FoodLife/
│   │   │   ├── FoodLifeApp.swift
│   │   │   ├── App/
│   │   │   │   ├── AppRootView.swift
│   │   │   │   └── AppNavigation.swift
│   │   │   ├── Domain/
│   │   │   │   ├── FoodMemory.swift
│   │   │   │   ├── MadeMemory.swift
│   │   │   │   ├── FoundMemory.swift
│   │   │   │   ├── PhotoReference.swift
│   │   │   │   └── FoodLifeError.swift
│   │   │   ├── Persistence/
│   │   │   │   ├── SwiftData/
│   │   │   │   │   ├── FoodMemoryRecord.swift
│   │   │   │   │   ├── PhotoReferenceRecord.swift
│   │   │   │   │   └── SwiftDataFoodMemoryRepository.swift
│   │   │   │   └── Conformance/
│   │   │   │       └── SchemaConformanceRunner.swift
│   │   │   ├── Services/
│   │   │   │   ├── FoodMemoryRepository.swift
│   │   │   │   ├── PhotoStore.swift
│   │   │   │   ├── LocalPhotoStore.swift
│   │   │   │   ├── LocationService.swift
│   │   │   │   ├── MapDisplayAdapter.swift
│   │   │   │   └── SeasonalRecapService.swift
│   │   │   ├── Features/
│   │   │   │   ├── Home/
│   │   │   │   ├── Made/
│   │   │   │   ├── Found/
│   │   │   │   ├── Timeline/
│   │   │   │   ├── AddMemory/
│   │   │   │   └── DetailEdit/
│   │   │   ├── DesignSystem/
│   │   │   │   ├── FoodLifeColors.swift
│   │   │   │   ├── FoodLifeTypography.swift
│   │   │   │   └── Components/
│   │   │   └── Resources/
│   │   │       ├── Assets.xcassets
│   │   │       └── Info.plist
│   │   ├── FoodLifeTests/
│   │   └── FoodLifeUITests/
│   └── web/
│       ├── index.html
│       ├── package.json
│       ├── vite.config.ts
│       ├── tsconfig.json
│       ├── vitest.config.ts
│       ├── src/
│       │   ├── main.tsx
│       │   ├── app/
│       │   │   ├── App.tsx
│       │   │   ├── routes.tsx
│       │   │   └── app-shell.tsx
│       │   ├── domain/
│       │   │   ├── food-memory.ts
│       │   │   ├── made-memory.ts
│       │   │   ├── found-memory.ts
│       │   │   ├── photo-reference.ts
│       │   │   └── food-life-error.ts
│       │   ├── persistence/
│       │   │   ├── indexed-db/
│       │   │   │   ├── food-life-db.ts
│       │   │   │   └── indexed-db-food-memory-repository.ts
│       │   │   ├── photo-store/
│       │   │   │   ├── opfs-photo-store.ts
│       │   │   │   └── indexed-db-photo-store.ts
│       │   │   └── conformance/
│       │   │       └── schema-conformance-runner.ts
│       │   ├── services/
│       │   │   ├── food-memory-repository.ts
│       │   │   ├── photo-store.ts
│       │   │   ├── location-service.ts
│       │   │   ├── map-display-adapter.ts
│       │   │   └── seasonal-recap-service.ts
│       │   ├── features/
│       │   │   ├── home/
│       │   │   ├── made/
│       │   │   ├── found/
│       │   │   ├── timeline/
│       │   │   ├── add-memory/
│       │   │   └── detail-edit/
│       │   ├── design-system/
│       │   │   ├── tokens.css
│       │   │   └── components/
│       │   └── test/
│       │       ├── setup.ts
│       │       └── test-utils.tsx
│       └── public/
├── packages/
│   └── schema-contract/
│       ├── package.json
│       ├── README.md
│       ├── schemas/
│       │   └── food-memory-v1.schema.json
│       ├── fixtures/
│       │   ├── made-memory.valid.json
│       │   ├── found-memory.valid.json
│       │   └── invalid/
│       ├── expected/
│       │   ├── timeline-order.json
│       │   └── seasonal-recap.json
│       ├── migrations/
│       │   └── v1.md
│       └── tests/
│           └── food-memory-contract.test.ts
└── _bmad-output/
    └── planning-artifacts/
```

### Architectural Boundaries

**API Boundaries:**
MVP has no backend API. All app behavior goes through service interfaces that are implemented locally in MVP and can receive remote implementations post-MVP.

**Backend-Ready Boundary:**
MVP must not implement a backend, authentication service, remote database, cloud sync, or cloud photo storage. However, MVP architecture must keep backend support easy to add later.

Backend-ready means:
- Repository interfaces must not expose SwiftData, IndexedDB, OPFS, or file-system-specific types.
- Domain models must be serializable through the canonical schema contract.
- Memory records must include stable IDs, `schemaVersion`, `createdAt`, and `updatedAt`.
- Photo metadata must be separate from photo binary storage.
- Local services should be named by capability, not storage technology.
- Domain errors should be stable enough to map to future API errors.
- Sync-sensitive decisions, such as deletion behavior and update timestamps, must be explicit in local contracts.

Post-MVP backend integration should be able to add:
- `RemoteFoodMemoryRepository`
- `RemotePhotoStore`
- sync orchestration
- conflict resolution
- account/auth boundaries
- cloud migration tooling

MVP should not add placeholder backend files, fake API clients, or unused server abstractions. Backend readiness is enforced through clean contracts, schema fixtures, and local repository boundaries.

**Component Boundaries:**
Feature UI must call services/repository interfaces, not persistence implementations directly. Shared UI primitives live in each platform's design-system area. Product-specific components live under their feature folder.

**Service Boundaries:**
- `FoodMemoryRepository` owns metadata CRUD and memory queries.
- `PhotoStore` owns image persistence and retrieval.
- `LocationService` owns permission-aware location capture.
- `MapDisplayAdapter` owns map rendering/fallback integration.
- `SeasonalRecapService` owns seasonal grouping and recap logic.

**Data Boundaries:**
Canonical schema fixtures live in `packages/schema-contract`. Platform stores may have native persistence types, but they must map to and from the canonical FoodMemory contract.

### Requirements to Structure Mapping

**Memory Type Model FR1-FR4:**
- `packages/schema-contract`
- `apps/ios/FoodLife/Domain`
- `apps/web/src/domain`

**Add Memory and Capture FR5-FR11:**
- `apps/ios/FoodLife/Features/AddMemory`
- `apps/web/src/features/add-memory`
- `PhotoStore`
- `LocationService`

**Made Memories FR12-FR16:**
- `apps/ios/FoodLife/Features/Made`
- `apps/web/src/features/made`

**Found Memories FR17-FR23:**
- `apps/ios/FoodLife/Features/Found`
- `apps/web/src/features/found`
- `MapDisplayAdapter`
- `LocationService`

**Memory Management FR24-FR28:**
- `Features/DetailEdit`
- `FoodMemoryRepository`
- persistence implementations

**Home and Seasonal Reflection FR29-FR32:**
- `Features/Home`
- `SeasonalRecapService`

**Timeline FR33-FR35:**
- `Features/Timeline`
- repository timeline query behavior
- `packages/schema-contract/expected/timeline-order.json`

**Platform Coverage FR36-FR40:**
- `apps/ios`
- `apps/web`
- `packages/schema-contract`

**Local-First Operation FR41-FR45:**
- platform persistence folders
- `PhotoStore`
- map/geocoding fallback adapters

### Integration Points

**Internal Communication:**
Views call feature view models/hooks. View models/hooks call service interfaces. Service implementations call platform persistence APIs. Persistence maps native records to canonical domain models.

**External Integrations:**
MVP external integration is limited to platform capabilities: camera, photo library, location, and map tiles/geocoding where available. These are adapter boundaries, not core domain dependencies.

**Data Flow:**
Add Memory creates a domain input, validates it, saves photo data through `PhotoStore`, stores photo refs in `FoodMemoryRepository`, then updates feature views through local query refresh.

### File Organization Patterns

**Configuration Files:**
Root config manages workspace-level scripts. Web config stays in `apps/web`. iOS config stays in the Xcode project. Schema contract config stays in `packages/schema-contract`.

**Source Organization:**
Source is split by platform and feature. Domain and service interfaces stay separate from persistence implementations.

**Test Organization:**
TDD tests are colocated for web feature/domain code, centralized for schema contract, and placed in Xcode test targets for iOS.

**Asset Organization:**
Static app assets live in platform folders. User photos are runtime data managed by `PhotoStore`, never committed assets.

### Development Workflow Integration

**Development Server Structure:**
Web runs from `apps/web`. iOS runs from `apps/ios` through Xcode. Schema contract tests run independently before platform conformance work.

**Build Process Structure:**
Web builds as a static SPA. iOS builds through Xcode. Schema contract package validates fixtures and expected behavior.

**Deployment Structure:**
Web deploys to static hosting. iOS deploys through TestFlight/App Store. No backend deployment exists for MVP, but deployment boundaries must not assume local-only forever.

## Architecture Validation Results

### Coherence Validation

**Decision Compatibility:**
The architecture decisions are compatible. SwiftUI/Xcode for iOS, Vite React TypeScript for web, and a shared schema contract provide separate platform implementations without losing product-model alignment. Local-first storage, photo-reference separation, TDD, and backend-ready contracts reinforce each other.

**Pattern Consistency:**
Implementation patterns support the core decisions. Naming rules preserve schema consistency. TDD rules protect behavior-bearing code. Error codes and service interfaces support both local MVP behavior and later backend/API mapping.

**Structure Alignment:**
The project structure supports the architecture. Platform-specific code stays under `apps/ios` and `apps/web`; shared conformance material stays under `packages/schema-contract`; feature folders map cleanly to PRD capability groups.

### Requirements Coverage Validation

**Feature Coverage:**
All major product surfaces are represented: Home, Made, Found, Timeline, Add Memory, Detail/Edit, shared schema contract, local persistence, photo storage, location/map adapters, and design-system areas.

**Functional Requirements Coverage:**
FR1-FR45 are architecturally supported through the schema contract, platform domain models, service interfaces, feature folders, persistence implementations, and map/photo fallback boundaries.

**Non-Functional Requirements Coverage:**
Performance targets are addressed through local repositories, timeline/recap services, photo reference separation, and testable query behavior. Privacy requirements are addressed by excluding auth/cloud/backend from MVP and limiting iOS permissions. Reliability is addressed through TDD, conformance tests, local persistence boundaries, and photo-reference integrity rules. Accessibility is supported by platform-specific UI structure and design-system boundaries.

### Implementation Readiness Validation

**Decision Completeness:**
Critical implementation decisions are documented: platform stack, local persistence, schema contract, photo storage separation, no backend in MVP, backend-ready boundaries, routing/state approach, TDD, and deployment posture.

**Structure Completeness:**
The directory structure is specific enough for implementation agents to place platform, feature, domain, persistence, service, design-system, and test code without inventing competing layouts.

**Pattern Completeness:**
Naming, structure, data formats, state management, error handling, loading states, TDD, and enforcement rules are defined. This is sufficient for consistent AI-agent implementation.

### Gap Analysis Results

**Critical Gaps:**
None.

**Important Gaps:**
- Deletion semantics are not fully defined. MVP can proceed, but backend/sync work will need explicit delete behavior, likely hard delete for local MVP and tombstone-ready metadata for future sync if delete becomes user-facing.

**Nice-to-Have Gaps:**
- Future CI details for Xcode are not fully specified because the MVP repository does not yet contain the iOS project.
- Future cloud sync conflict-resolution policy is intentionally deferred.

### Validation Issues Addressed

Backend readiness was clarified without adding backend implementation to MVP. The architecture now requires clean repository interfaces, serializable domain models, stable IDs and timestamps, photo metadata separation, stable domain errors, and no placeholder backend files.

### Architecture Completeness Checklist

**Requirements Analysis**
- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed
- [x] Technical constraints identified
- [x] Cross-cutting concerns mapped

**Architectural Decisions**
- [x] Critical decisions documented with versions
- [x] Technology stack fully specified
- [x] Integration patterns defined
- [x] Performance considerations addressed

**Implementation Patterns**
- [x] Naming conventions established
- [x] Structure patterns defined
- [x] Communication patterns specified
- [x] Process patterns documented

**Project Structure**
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped
- [x] Requirements to structure mapping complete

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** High

**Key Strengths:**
- Clear local-first architecture with future backend path.
- Strong schema-contract boundary between iOS and web.
- TDD requirement makes implementation behavior verifiable.
- Photo storage and metadata separation reduces future cloud migration risk.
- MVP excludes backend/auth/cloud without painting the product into a local-only corner.

**Areas for Future Enhancement:**
- Delete/tombstone policy before sync.
- Cloud sync provider and conflict model.
- Remote photo storage strategy.
- Xcode CI details after iOS project creation.
- Optional backend API design after MVP validation.

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented.
- Use implementation patterns consistently across all components.
- Respect project structure and backend-ready boundaries.
- Use TDD for behavior-bearing code.
- Refer to this document for all architectural questions.

**First Implementation Priority:**
Initialize the repository structure, create the Vite React TypeScript web app, create the iOS SwiftUI app shell, and create `packages/schema-contract` with FoodMemory v1 fixtures before feature implementation.
