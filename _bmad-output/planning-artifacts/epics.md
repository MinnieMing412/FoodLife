---
stepsCompleted:
  - step-01-validate-prerequisites
  - step-02-design-epics
  - step-03-create-stories
  - step-04-final-validation
inputDocuments:
  - /Users/yimingli/workspace/my_projects/FoodLife/_bmad-output/planning-artifacts/prd.md
  - /Users/yimingli/workspace/my_projects/FoodLife/_bmad-output/planning-artifacts/architecture.md
  - /Users/yimingli/workspace/my_projects/FoodLife/_bmad-output/planning-artifacts/ux-design-specification.md
---

# FoodLife - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for FoodLife, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: Users can classify each food memory as either Made or Found.
FR2: Users can create Made and Found memories using a shared underlying memory model.
FR3: Users can view Made and Found memories through type-specific experiences.
FR4: Users can distinguish Made and Found memories in combined views.
FR5: Users can start a global Add Memory flow from the app's primary navigation.
FR6: Users can choose Made or Found before entering memory details.
FR7: Users can attach a food photo to a new memory.
FR8: Users can create a memory from a newly captured photo.
FR9: Users can create a memory from an existing photo.
FR10: Users can save a memory with only the required fields for that memory type.
FR11: Users can add optional notes or context without blocking memory creation.
FR12: Users can create a Made memory with photo, dish name, ingredients, and date.
FR13: Users can add optional comfort level and personal context to a Made memory.
FR14: Users can view Made memories in a gallery-first browsing experience.
FR15: Users can open a Made memory detail view.
FR16: Users can view the photo, dish name, ingredients, date, and optional context for a Made memory.
FR17: Users can create a Found memory with photo, restaurant, location, and dining date.
FR18: Users can add optional discovery source and discovery context to a Found memory.
FR19: Users can mark whether a Found memory was a first visit.
FR20: Users can view Found memories in a map-first browsing experience.
FR21: Users can open a Found memory detail view.
FR22: Users can view the photo, restaurant, location, dining date, and optional context for a Found memory.
FR23: Users can browse Found memories using saved location metadata.
FR24: Users can edit an existing Made memory.
FR25: Users can edit an existing Found memory.
FR26: Users can update memory photos and metadata after creation.
FR27: Users can preserve saved memories locally.
FR28: Users can retrieve saved memories locally across app sessions.
FR29: Users can view a Home experience that reflects their recent food memories through gentle seasonal language and photo-led presentation.
FR30: Users can view a seasonal recap generated from saved Made and Found memories.
FR31: Users can see Made and Found memories together in seasonal context.
FR32: Users can navigate from Home recap content to related memory details.
FR33: Users can view all Made and Found memories together in a chronological Timeline.
FR34: Users can open memory details from Timeline.
FR35: Users can distinguish memory type while browsing Timeline.
FR36: Users can complete core create, edit, browse, and detail workflows in the iOS app.
FR37: Users can complete core create, edit, browse, and detail workflows in the web app.
FR38: Users can access the same conceptual product structure on iOS and web.
FR39: The system can represent memories using a shared FoodMemory schema across platforms.
FR40: The system can support platform-specific storage implementations behind a consistent storage abstraction.
FR41: Users can use FoodLife without creating an account.
FR42: Users can create and edit local memories without cloud sync.
FR43: Users can browse local memories without cloud sync.
FR44: Users can access locally stored photos associated with saved memories.
FR45: The system can preserve memory metadata when map services or geocoding are unavailable.

### NonFunctional Requirements

NFR1: Core local navigation between Home, Made, Found, Timeline, and memory detail views must render already-stored local data within 500 ms for a local archive of 2,000 memories on supported devices, measured in platform performance tests.
NFR2: Creating or updating a memory must require no more than four required user-entered metadata fields after photo selection for each memory type, measured by form requirements review.
NFR3: Made gallery and Timeline views must remain usable with at least 2,000 memories and associated local photo references, measured by platform tests for scrolling, opening details, and chronological ordering.
NFR4: Home seasonal recap generation must complete within 1 second for an archive of 2,000 memories or run asynchronously without blocking navigation, measured by local performance tests.
NFR5: Found map browsing must preserve saved memory cards and location metadata when map tiles or geocoding are unavailable, measured by offline or failed-service test scenarios.
NFR6: FoodLife v1 must not require account creation, authentication, or cloud sync.
NFR7: FoodLife v1 must store personal food memories and photos locally by default.
NFR8: The app must request only MVP-required permissions: camera, photo library, and location.
NFR9: The app must explain permission use in product context before or during permission requests.
NFR10: The MVP must not expose memories publicly or create social visibility by default.
NFR11: If future sync or sharing is added, it must not require changing the core FoodMemory schema.
NFR12: Saved memories must remain available after app restart and device/browser restart in supported local storage environments, measured by persistence tests.
NFR13: Saved photos must remain associated with the correct memory record across create, edit, detail, gallery, timeline, and map workflows, measured by regression tests.
NFR14: Editing a memory must preserve unchanged fields and photo references unless the user explicitly modifies them, measured by update-flow tests.
NFR15: Failed or unavailable map/geocoding services must not prevent saving a Found memory with manually entered restaurant and location metadata, measured by failed-service tests.
NFR16: iOS and web implementations must pass the same FoodMemory schema conformance cases for Made and Found records before MVP release.
NFR17: Web core create, edit, browse, and detail workflows must target WCAG 2.2 AA; iOS equivalents must support platform accessibility labels, readable text scaling, and accessible control focus, measured by accessibility review.
NFR18: Text, controls, and memory metadata must remain readable and non-overlapping across mobile, tablet, desktop, and wide desktop viewport classes, measured by responsive layout review.
NFR19: Food photos must not be the only way to identify a memory; dish, restaurant, date, or location text metadata must remain available in browsing and detail contexts, measured by UX review.
NFR20: Visual mood differences between Made and Found must not rely on color alone; labels, structure, or iconography must also communicate type, measured by accessibility review.
NFR21: The FoodMemory schema must represent Made and Found records without platform-only required fields, verified by shared schema review before implementation.
NFR22: Photo references must be modeled separately from memory metadata so local photo storage in v1 can be replaced by cloud photo storage later without redefining memory records, verified by architecture review.
NFR23: Platform-specific storage implementations must support the same create, read, update, delete, list, detail, timeline, seasonal grouping, and location-retrieval behavior contract, verified by shared conformance tests.
NFR24: MVP architecture must document a migration path for future multi-device continuity before implementation begins, verified during architecture review.
NFR25: Scope changes that alter platform coverage, permissions, data storage, sync, sharing, public visibility, location behavior, or browser support must trigger PRD review of FRs, NFR thresholds, viewport targets, permission assumptions, privacy disclosures, and architecture handoff requirements before implementation.

### Additional Requirements

- Initialize separate app starters in one repository: native SwiftUI iOS app in `apps/ios`, Vite React TypeScript web app in `apps/web`, and shared schema contract assets in `packages/schema-contract`.
- Create the FoodMemory v1 schema contract before feature work, including canonical JSON fixtures, validation rules, migration notes, expected timeline ordering, and expected seasonal recap output.
- Use SwiftData for iOS metadata persistence unless implementation spikes reveal blocking migration or query limitations.
- Use IndexedDB for web metadata persistence, with Dexie or a similarly small wrapper where it simplifies upgrades and transactions.
- Use OPFS for web photo/blob storage where available, with IndexedDB Blob fallback.
- Keep memory metadata separate from photo binaries; memory records store `photoRefs`, never embedded full image blobs.
- Define `FoodMemoryRepository`, `PhotoStore`, `LocationService`, `MapDisplayAdapter`, `SeasonalRecapService`, and `SchemaConformanceRunner` boundaries before UI depends on them.
- Implement map and geocoding as replaceable platform adapters; map/geocoding failures must not block saving a Found memory with manual restaurant and location metadata.
- Exclude backend APIs, authentication, authorization, cloud sync, cloud photo storage, public sharing, and server infrastructure from MVP implementation.
- Keep repository interfaces serializable and backend-ready without adding placeholder backend files, fake API clients, or unused server abstractions.
- Use stable domain error codes: `validation_failed`, `photo_save_failed`, `photo_missing`, `storage_unavailable`, `quota_exceeded`, `location_unavailable`, `map_unavailable`, and `migration_unsupported`.
- Use camelCase canonical schema fields, ISO 8601 dates, string IDs, `type` discriminator values of `made` or `found`, explicit `schemaVersion`, and stable `createdAt` / `updatedAt` fields.
- Follow repository method naming conventions such as `createMemory`, `updateMemory`, `deleteMemory`, `getMemory`, and `listTimeline`.
- Preserve architectural naming and file placement conventions for TypeScript, React components, Swift files, product feature folders, service interfaces, persistence implementations, and tests.
- Use TDD for behavior-bearing code, including schema contract validation, repository behavior, photo storage behavior, timeline sorting, seasonal recap generation, map fallback behavior, save/update flows, domain error mapping, and accessibility-critical components where testable.
- Require implementation handoffs to report the failing test added first, relevant command results, passing tests, and any explicitly untested behavior.
- Web implementation must use React Router for Home, Made, Found, Timeline, Add Memory, and Detail/Edit routes.
- Web implementation must use Tailwind CSS via Vite plugin with FoodLife tokens expressed as CSS/theme variables.
- Web implementation must use Vitest for unit tests, schema conformance tests, local repository tests, recap/timeline logic, and focused component behavior tests.
- iOS implementation must use SwiftUI-native views and platform adapters for camera, photo library, location, and maps.
- iOS implementation must support XCTest and UI tests for schema conformance, repository behavior, recap/timeline logic, storage/photo reference behavior, Add Memory, and edit flows.
- CI direction must include web install/typecheck/test/build and schema-contract validation; iOS build/test should be added when CI supports Xcode.
- MVP deployment must be static SPA hosting for web and TestFlight/App Store path for iOS, with no backend deployment.

### UX Design Requirements

UX-DR1: Implement FoodLife around six conceptual destinations: Home, Made, Found, Timeline, Add Memory, and Detail View across both iOS and web.
UX-DR2: Preserve the Made / Found emotional split throughout navigation, capture, browsing, detail, edit, labels, metadata hierarchy, and visual treatment.
UX-DR3: Use a photo-first hierarchy where food photos carry the primary memory impression and metadata supports recall without dominating browsing.
UX-DR4: Start Add Memory with a type-first Made / Found selection before photo and detail entry.
UX-DR5: Present Made and Found choices with label, icon, short description, selected state, and accessible selection semantics.
UX-DR6: Prompt the user to take a photo or choose from photo library immediately after type selection.
UX-DR7: Keep the selected photo visible during Add Memory detail entry.
UX-DR8: Made forms must ask for dish name, ingredients, and date, with optional comfort level and note/context.
UX-DR9: Found forms must ask for restaurant, location, and dining date, with optional discovery source, first-visit marker, and note/context.
UX-DR10: Required fields must be clearly marked, validation must be inline and recoverable, and optional fields must not block save.
UX-DR11: Save completion must confirm local preservation and show or route to the correct destination: Made gallery, Found map/preview, Timeline, Home, or Detail View.
UX-DR12: Editing must mirror create flows, preserve unchanged fields and photo references, and frame corrections as completing a memory rather than fixing a mistake.
UX-DR13: Home must use Seasonal Cover Home direction with standout seasonal imagery, reflective language, Made/Found previews, and a route into Timeline or related details.
UX-DR14: Home empty or low-data states must feel like starter chapters and invite capture without pressure.
UX-DR15: Made must use Made Gallery Calm direction: warm, restrained, photo-led gallery browsing with ingredient context revealed progressively.
UX-DR16: Found must use Found Map Fresh direction: map-first browsing with vivid Market Green markers, place context, and photo-led previews.
UX-DR17: Found must provide an accessible list, preview, or detail alternative when map rendering or geocoding is unavailable.
UX-DR18: Timeline must use Timeline as Food Life direction: chronological Made/Found browsing with date grouping, type labels/icons, metadata hierarchy, and clear detail navigation.
UX-DR19: Detail View must use Editorial Detail View direction with dominant photo, type label, title, date, primary context, optional notes, and edit action.
UX-DR20: Use the Porcelain & Market Green palette as the core visual foundation: background `#F7F5F0`, surface `#FFFFFF`, text `#24221F`, Made `#C1A79C`, Found `#7CB342`, Seasonal `#B9A36A`, Accent `#1E9E8A`, Muted `#7B7770`.
UX-DR21: Use Made color as a restrained warm accent, not low-contrast body text.
UX-DR22: Use Found color for map markers, discovery indicators, active Found navigation, location metadata, and place preview states, with contrast checked before text use.
UX-DR23: Use Seasonal color carefully for Home chapter labels, recap highlights, and seasonal modules rather than dominant backgrounds.
UX-DR24: Use clean, readable sans-serif typography with native iOS typography behavior respected and no decorative food-blog or technical dashboard styling.
UX-DR25: Use an 8px spacing foundation and keep cards restrained with corner radius no larger than 8px unless platform-native components require otherwise.
UX-DR26: Avoid nested cards, heavy decorative containers, ratings widgets, social-feed components, nutrition dashboards, recipe-builder modules, and analytics charts in MVP.
UX-DR27: Implement stable photo aspect ratios for Made gallery, Found previews, Timeline rows, Home modules, and Detail View to prevent layout shifts.
UX-DR28: Build reusable components for app navigation, global Add Memory action, Made/Found selector, photo picker entry point, memory card, Made gallery item, Found map marker, map memory preview, timeline item, seasonal recap module, detail header, editable field group, form action bar, empty state, permission prompt, offline/map fallback state, loading states, and error states.
UX-DR29: Memory Card accessible names must include memory type, title, date, and primary context.
UX-DR30: Found map markers must be keyboard reachable or represented in an accessible list alternative, with labels including restaurant, location, and date where available.
UX-DR31: Map Memory Preview must adapt to bottom sheet on mobile and side/floating panel on tablet/desktop, with route to full detail and dismiss behavior.
UX-DR32: Empty, permission, fallback, loading, success, warning, and error states must use clear non-alarming language, reachable actions, and assistive technology exposure where appropriate.
UX-DR33: Permission prompts must explain camera, photo library, and location use in FoodLife product language.
UX-DR34: Primary navigation must center on Home, Made, Found, and Timeline, with Add Memory globally available.
UX-DR35: Opening details from Home, Made, Found, or Timeline must preserve predictable return context.
UX-DR36: Mobile navigation must prioritize thumb reach and clear tab behavior; desktop web may use top or side navigation while preserving conceptual destinations.
UX-DR37: Add Memory and edit flows should use focused full-screen or sustained-attention layouts because photo and form content require focus.
UX-DR38: Use mobile-first responsive web behavior across mobile `320px-767px`, tablet `768px-1023px`, desktop `1024px-1439px`, and wide desktop `1440px+`.
UX-DR39: Mobile layouts must collapse Home, Made, Found, Timeline, Add Memory, and Detail View to single-column flows.
UX-DR40: Tablet and desktop layouts may enhance browsing with wider grids, map plus preview panels, grouped timeline layouts, split photo/form layouts, and photo/metadata detail columns without changing product behavior.
UX-DR41: Web core workflows must target WCAG 2.2 AA, semantic HTML, logical headings, associated form labels, visible focus states, keyboard navigation, and screen-reader compatible feedback.
UX-DR42: iOS workflows must support VoiceOver, Dynamic Type/readable text scaling, accessible focus order, platform-native controls, and clear labels for actionable controls.
UX-DR43: Made and Found distinctions must use labels, icons, structure, metadata hierarchy, and section context in addition to color.
UX-DR44: Food photos must never be the only memory identifier; browse and detail surfaces must expose dish name, restaurant name, date, ingredients, location, or other text metadata.
UX-DR45: Touch and click targets should be at least 44x44px where feasible for Add Memory, navigation, photo source actions, save/edit controls, map markers/list alternatives, and sheet dismissals.
UX-DR46: Responsive and accessibility testing must cover Home, Made gallery, Found map, Timeline, Add Memory, Detail View, edit flow, empty states, loading states, fallback states, current Safari and Chrome, VoiceOver, keyboard-only navigation, text scaling, color contrast, and non-overlapping layouts.

### FR Coverage Map

FR1: Epic 1 - Made/Found memory type model.
FR2: Epic 1 - Shared underlying memory model.
FR3: Epics 3 and 4 - Type-specific Made and Found experiences.
FR4: Epics 1 and 6 - Type distinction in combined model and combined views.
FR5: Epic 2 - Global Add Memory flow.
FR6: Epic 2 - Type-first Made/Found selection before details.
FR7: Epic 2 - Photo attachment for new memories.
FR8: Epic 2 - Create memory from newly captured photo.
FR9: Epic 2 - Create memory from existing photo.
FR10: Epic 2 - Save with required fields only.
FR11: Epic 2 - Optional notes/context without blocking creation.
FR12: Epic 2 - Made memory creation with photo, dish name, ingredients, and date.
FR13: Epic 2 - Optional Made comfort level and personal context.
FR14: Epic 3 - Made gallery-first browsing.
FR15: Epic 3 - Made detail view.
FR16: Epic 3 - Made photo, dish, ingredients, date, and context display.
FR17: Epic 2 - Found memory creation with photo, restaurant, location, and dining date.
FR18: Epic 2 - Optional Found discovery source and context.
FR19: Epic 2 - Found first-visit marker.
FR20: Epic 4 - Found map-first browsing.
FR21: Epic 4 - Found detail view.
FR22: Epic 4 - Found photo, restaurant, location, dining date, and context display.
FR23: Epic 4 - Browse Found memories using saved location metadata.
FR24: Epic 5 - Edit existing Made memories.
FR25: Epic 5 - Edit existing Found memories.
FR26: Epic 5 - Update memory photos and metadata.
FR27: Epics 1 and 5 - Local memory preservation and edit durability.
FR28: Epics 1 and 5 - Local retrieval across app sessions.
FR29: Epic 6 - Home seasonal reflection experience.
FR30: Epic 6 - Seasonal recap from saved Made and Found memories.
FR31: Epic 6 - Made and Found memories together in seasonal context.
FR32: Epic 6 - Navigate from Home recap to related details.
FR33: Epic 6 - Chronological Timeline for all memories.
FR34: Epic 6 - Open memory details from Timeline.
FR35: Epic 6 - Distinguish memory type in Timeline.
FR36: Epic 1 - Complete iOS core workflow platform foundation.
FR37: Epic 1 - Complete web core workflow platform foundation.
FR38: Epic 1 - Same conceptual product structure on iOS and web.
FR39: Epic 1 - Shared FoodMemory schema across platforms.
FR40: Epic 1 - Platform-specific storage behind consistent abstraction.
FR41: Epic 1 - No-account local-first use.
FR42: Epics 1 and 2 - Create and edit local memories without cloud sync.
FR43: Epics 1 and 6 - Browse local memories without cloud sync.
FR44: Epics 1, 2, and 5 - Local photo access and photo association.
FR45: Epics 2 and 4 - Preserve Found memory metadata when map/geocoding services are unavailable.

## Epic List

### Epic 1: Local-First FoodLife Foundation
Users can open complete iOS and web app shells, navigate the core product structure, and rely on a shared local-first FoodMemory model that preserves metadata and photo references across sessions.
**FRs covered:** FR1, FR2, FR4, FR27, FR28, FR36, FR37, FR38, FR39, FR40, FR41, FR42, FR43, FR44

**Implementation guardrail:** Foundation work in this epic must stay limited to FoodLife MVP outcomes: app shells, shared schema contract, local repository/photo boundaries, navigation, design tokens, and conformance/verification automation. Do not expand this epic into generic infrastructure, backend placeholders, cloud abstractions, or non-MVP platform services.

### Epic 2: Photo-First Memory Capture
Users can start Add Memory globally, choose Made or Found first, attach or capture a photo, complete only required type-specific fields, add optional context, and save local memories reliably.
**FRs covered:** FR5, FR6, FR7, FR8, FR9, FR10, FR11, FR12, FR13, FR17, FR18, FR19, FR42, FR44, FR45

### Epic 3: Made Memories Gallery and Detail
Users can browse Made memories in a warm gallery-first experience, open Made detail views, and recognize each home-cooked memory through photo, dish, ingredients, date, and optional context.
**FRs covered:** FR3, FR14, FR15, FR16

### Epic 4: Found Memories Map and Detail
Users can browse Found memories through a map-first place-aware experience, preserve location context when services fail, and open Found detail views with restaurant, location, date, and optional discovery context.
**FRs covered:** FR3, FR20, FR21, FR22, FR23, FR45

### Epic 5: Edit and Maintain Memories
Users can correct or complete Made and Found memories later, including metadata and photos, while preserving unchanged fields and local photo associations.
**FRs covered:** FR24, FR25, FR26, FR27, FR28, FR44

### Epic 6: Home Seasonal Reflection and Timeline Rediscovery
Users can rediscover their food life through a gentle seasonal Home recap and a chronological Timeline that combines Made and Found memories while preserving type clarity and detail navigation.
**FRs covered:** FR4, FR29, FR30, FR31, FR32, FR33, FR34, FR35, FR43

## Epic 1: Local-First FoodLife Foundation

Users can open complete iOS and web app shells, navigate the core product structure, and rely on a shared local-first FoodMemory model that preserves metadata and photo references across sessions.

### Story 1.1: Set Up Initial Project from Starter Templates

As a FoodLife user,
I want the iOS and web apps to open into the same core product structure,
So that FoodLife feels like one coherent local-first archive across platforms.

**Requirements:** FR36, FR37, FR38, FR41

**Acceptance Criteria:**

**Given** the FoodLife repository has no implementation app shells
**When** the workspace is initialized
**Then** it contains `apps/ios`, `apps/web`, and `packages/schema-contract` following the architecture structure
**And** the web app is initialized from the Vite React TypeScript starter with route placeholders for Home, Made, Found, Timeline, Add Memory, and Detail/Edit
**And** the iOS app shell is initialized from the native SwiftUI Xcode app template with matching conceptual navigation placeholders
**And** the web app dependency install, initial test command, and production build command are documented and verified
**And** the iOS app build can be verified locally in Xcode, or any unavailable Xcode automation constraint is explicitly documented
**And** no backend, authentication, cloud sync, or placeholder server API is introduced.

### Story 1.2: Define FoodMemory v1 Schema Contract

As a FoodLife user,
I want Made and Found memories to share a consistent model,
So that my archive behaves the same on iOS and web.

**Requirements:** FR1, FR2, FR4, FR39

**Acceptance Criteria:**

**Given** the schema contract package exists
**When** FoodMemory v1 is defined
**Then** it includes common fields, Made metadata, Found metadata, `schemaVersion`, string IDs, ISO 8601 dates, and `type` discriminator values of `made` or `found`
**And** photo references are modeled separately from memory metadata through `photoRefs`
**And** valid Made and Found fixtures are included
**And** invalid fixtures cover unsupported type values and missing required shared fields
**And** schema contract tests verify the fixtures and fail on contract violations.

### Story 1.3: Establish Baseline CI and Verification Workflow

As a FoodLife developer,
I want schema-contract and web verification to run through documented commands and baseline CI,
So that implementation agents get fast feedback before feature work depends on the foundation.

**Requirements:** FR37, FR39, FR40

**Acceptance Criteria:**

**Given** the web app starter and schema-contract package exist
**When** baseline verification is configured
**Then** the repository exposes documented commands for web install, typecheck, test, and build
**And** the schema-contract package exposes a documented validation/test command for fixtures and expected outputs
**And** baseline CI or equivalent repository automation runs schema-contract validation and web typecheck/test/build
**And** iOS build/test automation is added when an Xcode-capable CI runner is available, or the local Xcode verification path is documented
**And** no backend deployment, cloud service, or non-MVP infrastructure is introduced.

### Story 1.4: Implement Web Local Repository Contract

As a FoodLife user,
I want the web app to preserve local memory records across browser sessions,
So that my food archive remains available without an account or cloud sync.

**Requirements:** FR27, FR28, FR37, FR40, FR41, FR42, FR43

**Acceptance Criteria:**

**Given** FoodMemory v1 fixtures exist
**When** the web local repository is implemented
**Then** it exposes the agreed repository methods for create, update, delete, get, and list behavior needed by future stories
**And** it persists metadata locally with IndexedDB-compatible storage
**And** it maps persisted records to the canonical FoodMemory contract
**And** repository conformance tests cover Made and Found records, local retrieval after restart simulation, and no network dependency
**And** no UI feature depends directly on IndexedDB implementation details.

### Story 1.5: Implement Web Photo Reference Store Boundary

As a FoodLife user,
I want saved web memories to keep stable photo references,
So that photos can remain associated with the correct records as the archive grows.

**Requirements:** FR40, FR44

**Acceptance Criteria:**

**Given** web memory records store `photoRefs`
**When** the web photo store boundary is implemented
**Then** it supports stable photo IDs, storage kind, local key/path, created date, and optional thumbnail key
**And** it can use OPFS where available with IndexedDB Blob fallback
**And** tests verify photo metadata remains separate from FoodMemory records
**And** tests verify memory records never embed image blobs
**And** photo lookup errors map to stable domain error codes.

### Story 1.6: Implement iOS Domain and Repository Contract

As a FoodLife user,
I want the iOS app to preserve local memory records using the same FoodMemory meaning as web,
So that FoodLife does not split into incompatible archives.

**Requirements:** FR27, FR28, FR36, FR39, FR40, FR41, FR42, FR43, FR44

**Acceptance Criteria:**

**Given** FoodMemory v1 fixtures exist
**When** the iOS domain and repository contract are implemented
**Then** Swift domain models represent Made and Found memories with the canonical fields and discriminator semantics
**And** SwiftData persistence stores local metadata without embedding photo binaries
**And** XCTest conformance cases validate Made and Found fixture compatibility
**And** local retrieval across app relaunch scenarios is covered by tests where feasible
**And** SwiftData model objects do not become the canonical schema source.

### Story 1.7: Establish Shared Navigation and Design Tokens

As a FoodLife user,
I want Home, Made, Found, Timeline, and Add Memory to be consistently reachable and visually coherent,
So that the app feels understandable before feature-specific screens are complete.

**Requirements:** FR4, FR36, FR37, FR38

**Acceptance Criteria:**

**Given** iOS and web app shells exist
**When** shared navigation and base design tokens are implemented
**Then** both platforms expose Home, Made, Found, Timeline, and global Add Memory entry points
**And** route or screen placeholders use clear Made/Found labels and non-color-only type cues
**And** web tokens include the Porcelain & Market Green palette, typography foundation, spacing foundation, and focus treatment
**And** iOS tokens map the same product roles to SwiftUI-native styling foundations
**And** web navigation is keyboard reachable and iOS navigation has accessible labels.

## Epic 2: Photo-First Memory Capture

Users can start Add Memory globally, choose Made or Found first, attach or capture a photo, complete only required type-specific fields, add optional context, and save local memories reliably.

### Story 2.1: Launch Type-First Add Memory Flow

As a FoodLife user,
I want to start Add Memory from primary navigation and choose Made or Found first,
So that the capture flow immediately matches the kind of memory I am preserving.

**Requirements:** FR5, FR6

**Acceptance Criteria:**

**Given** the app shell exposes global Add Memory
**When** I start Add Memory
**Then** I see Made and Found as the first required choice
**And** each choice has a label, icon, short description, selected state, and accessible selection semantics
**And** selecting Made or Found changes the flow language and required metadata path
**And** I can cancel and return to the previous navigation context.

### Story 2.2: Add Photo Picker Entry Point

As a FoodLife user,
I want to take a new photo or choose an existing food photo after selecting memory type,
So that the photo becomes the anchor of the memory.

**Requirements:** FR7, FR8, FR9, FR44

**Acceptance Criteria:**

**Given** I selected Made or Found in Add Memory
**When** I reach the photo step
**Then** I can choose between taking a photo and selecting from photo library where supported
**And** permission prompts explain camera and photo-library usage in FoodLife terms
**And** permission denial provides a recoverable state rather than ending the flow abruptly
**And** the selected photo remains visible during detail entry
**And** the photo is saved through the platform photo store boundary and referenced through `photoRefs`.

### Story 2.3: Create Made Memory with Required and Optional Context

As a FoodLife user,
I want to save a Made memory with a photo, dish name, ingredients, date, and optional comfort context,
So that food I cooked is preserved quickly without recipe-management overhead.

**Requirements:** FR10, FR11, FR12, FR13, FR42, FR44

**Acceptance Criteria:**

**Given** I selected Made and added a photo
**When** I enter dish name, ingredients, and date
**Then** I can save the Made memory locally
**And** comfort level and note/context are optional and never block save
**And** validation is inline, specific, and recoverable for missing required fields
**And** the flow requires no more than the PRD-defined required Made metadata fields after photo selection
**And** save completion confirms local preservation and indicates the memory belongs in Made, Timeline, and Home.

### Story 2.4: Create Found Memory with Location and Discovery Context

As a FoodLife user,
I want to save a Found memory with a photo, restaurant, location, dining date, and optional discovery context,
So that a dining-out discovery is remembered by place without becoming a public review.

**Requirements:** FR10, FR11, FR17, FR18, FR19, FR42, FR44

**Acceptance Criteria:**

**Given** I selected Found and added a photo
**When** I enter restaurant, location, and dining date
**Then** I can save the Found memory locally
**And** discovery source, first-visit marker, and note/context are optional and never block save
**And** the flow avoids ratings, public review language, restaurant search framing, price analysis, and social posting language
**And** validation is inline, specific, and recoverable for missing required fields
**And** save completion confirms local preservation and indicates the memory belongs in Found, Timeline, and Home.

### Story 2.5: Preserve Found Memory When Location Services Fail

As a FoodLife user,
I want to save a Found memory even if location services, map tiles, or geocoding are unavailable,
So that my food memory is not lost because a platform service failed.

**Requirements:** FR17, FR23, FR45

**Acceptance Criteria:**

**Given** I am creating a Found memory
**When** location services, map tiles, or geocoding are unavailable
**Then** I can manually enter restaurant and location metadata
**And** the unavailable service is communicated through a clear non-alarming fallback state
**And** saving succeeds when the required manual fields are complete
**And** the record preserves location label metadata for later Found browsing
**And** service failures map to stable domain errors without blocking local metadata preservation.

### Story 2.6: Validate Capture Persistence Across Web and iOS

As a FoodLife user,
I want newly saved Made and Found memories to remain available after app or browser restart,
So that I can trust FoodLife as a local archive.

**Requirements:** FR27, FR28, FR42, FR44

**Acceptance Criteria:**

**Given** Made and Found capture flows can save local records
**When** a memory is saved and the app or browser session restarts
**Then** the saved metadata can be retrieved from local storage
**And** the saved photo reference remains associated with the correct memory
**And** platform tests cover Made save, Found save, required-field validation, optional context, and photo-reference association
**And** no network connection, account, cloud sync, or backend API is required.

## Epic 3: Made Memories Gallery and Detail

Users can browse Made memories in a warm gallery-first experience, open Made detail views, and recognize each home-cooked memory through photo, dish, ingredients, date, and optional context.

### Story 3.1: Browse Made Memories in a Gallery

As a FoodLife user,
I want to browse my Made memories in a warm photo-led gallery,
So that food I cooked feels easy and pleasant to revisit.

**Requirements:** FR3, FR14, FR16

**Acceptance Criteria:**

**Given** saved Made memories exist locally
**When** I open Made
**Then** I see Made memories in a gallery-first layout
**And** each gallery item shows a stable-ratio photo, dish name, ingredient preview or date, and Made type cue
**And** Made uses warm restrained styling with non-color-only type distinction
**And** the gallery remains usable with local photo references and supports loading or missing-image states
**And** Found memories do not appear in the Made gallery.

### Story 3.2: Support Made Empty, Loading, and Error States

As a FoodLife user,
I want the Made gallery to handle empty, loading, and photo-error states gracefully,
So that the app still feels trustworthy when my archive is new or a photo cannot render.

**Requirements:** FR14, FR16

**Acceptance Criteria:**

**Given** I open Made with no Made memories
**When** the gallery loads
**Then** I see an emotionally aligned empty state inviting the first home-cooked memory
**And** loading states reserve layout space to avoid visual jumps
**And** missing-photo states still show dish name, date, and available context
**And** errors are specific, non-alarming, and do not imply metadata was lost
**And** primary actions remain keyboard/touch reachable.

### Story 3.3: Open Made Memory Detail View

As a FoodLife user,
I want to open a Made memory from the gallery,
So that I can revisit the photo and context behind a dish I cooked.

**Requirements:** FR15, FR16

**Acceptance Criteria:**

**Given** a Made memory appears in the gallery
**When** I select it
**Then** the Made detail view opens
**And** the detail header presents the photo as the dominant memory object
**And** the view shows dish name, date, ingredients, optional comfort level, and optional note/context
**And** the detail view uses Made-specific labels and warm restrained accents
**And** the return path goes back to the Made gallery context.

### Story 3.4: Make Made Browse and Detail Accessible and Responsive

As a FoodLife user,
I want Made gallery and detail screens to work across screen sizes and accessibility modes,
So that I can revisit home-cooked memories comfortably on iOS and web.

**Requirements:** FR3, FR14, FR15, FR16

**Acceptance Criteria:**

**Given** Made gallery and detail are implemented
**When** they are viewed on mobile, tablet, desktop, and wide desktop web sizes
**Then** content remains readable, non-overlapping, and photo-led
**And** mobile uses a single-column or compact gallery pattern while larger screens can expand to multi-column layouts
**And** gallery items and detail actions have accessible names that include type, dish name, date, and primary context
**And** Made distinction does not rely on color alone
**And** web supports keyboard navigation and visible focus, while iOS supports VoiceOver labels and readable text scaling
**And** responsive/accessibility verification covers Made empty, loading, missing-photo, gallery, and detail states across mobile, tablet, desktop, and wide desktop web sizes
**And** assistive-technology verification covers keyboard-only web navigation, visible focus order, screen reader labels, and iOS readable text scaling.

## Epic 4: Found Memories Map and Detail

Users can browse Found memories through a map-first place-aware experience, preserve location context when services fail, and open Found detail views with restaurant, location, date, and optional discovery context.

### Story 4.1: Browse Found Memories on a Map

As a FoodLife user,
I want to browse Found memories on a personal map,
So that dining-out discoveries feel anchored to place.

**Requirements:** FR3, FR20, FR23

**Acceptance Criteria:**

**Given** saved Found memories with location metadata exist locally
**When** I open Found
**Then** I see a map-first browsing experience
**And** Found memories appear through location-aware markers or equivalent platform-native map annotations
**And** markers use Found-specific styling and non-color-only accessible labels where feasible
**And** saved restaurant, location, and date metadata remain available from the map experience
**And** Made memories do not appear as Found map entries.

### Story 4.2: Open Found Map Memory Preview

As a FoodLife user,
I want to select a Found map marker and see a photo-led preview,
So that I can recognize the place before opening the full memory.

**Requirements:** FR20, FR21, FR22, FR23

**Acceptance Criteria:**

**Given** a Found memory appears on the map
**When** I select its marker or accessible list equivalent
**Then** a Map Memory Preview appears with photo, restaurant name, location, date, and optional discovery or first-visit context
**And** the preview includes an action to open the full Found detail view
**And** mobile uses a bottom-sheet style preview where appropriate
**And** tablet and desktop can use a side or floating preview panel
**And** dismissing the preview returns to the map context predictably.

### Story 4.3: Provide Found Map Fallback and Accessible Alternative

As a FoodLife user,
I want Found memories to remain browsable when map services are unavailable or inaccessible,
So that saved dining memories are not dependent on map rendering.

**Requirements:** FR20, FR21, FR22, FR23, FR45

**Acceptance Criteria:**

**Given** Found memories exist locally
**When** map tiles, geocoding, map permissions, or map rendering are unavailable
**Then** Found shows a clear fallback state and an accessible list or preview alternative
**And** each fallback item exposes restaurant, location, date, type, and photo or missing-photo state
**And** map/geocoding failures do not remove or modify saved memory metadata
**And** the fallback still lets me open Found detail views
**And** service failures map to stable domain errors.

### Story 4.4: Open Found Memory Detail View

As a FoodLife user,
I want to open a Found memory detail view,
So that I can revisit the photo, restaurant, place, and discovery context behind a meal.

**Requirements:** FR21, FR22

**Acceptance Criteria:**

**Given** a Found memory is selected from map, preview, fallback list, or another route
**When** the Found detail view opens
**Then** the detail header presents the food photo as the dominant memory object
**And** the view shows restaurant, location, dining date, optional discovery source, optional first-visit marker, and optional note/context
**And** the detail view uses Found-specific labels and Market Green discovery accents without relying on color alone
**And** it avoids rating, public review, restaurant search, price, and social posting patterns
**And** the return path goes back to the originating Found context where possible.

### Story 4.5: Make Found Map and Detail Accessible and Responsive

As a FoodLife user,
I want Found map and detail screens to work across screen sizes and accessibility modes,
So that I can revisit dining discoveries comfortably on iOS and web.

**Requirements:** FR3, FR20, FR21, FR22, FR23

**Acceptance Criteria:**

**Given** Found map, preview, fallback, and detail are implemented
**When** they are viewed on mobile, tablet, desktop, and wide desktop web sizes
**Then** content remains readable, non-overlapping, and photo-led
**And** mobile uses map plus bottom-sheet/list patterns while larger screens can use map plus side preview
**And** web supports keyboard navigation to Found memories through marker alternatives or list representations
**And** screen reader labels include type, restaurant, location, and date
**And** iOS supports VoiceOver labels, native map affordances where feasible, and readable text scaling
**And** responsive/accessibility verification covers Found empty, loading, map available, map unavailable, geocoding unavailable, preview, fallback list, and detail states across mobile, tablet, desktop, and wide desktop web sizes
**And** map verification confirms every Found memory remains reachable without relying on pointer-only map markers.

## Epic 5: Edit and Maintain Memories

Users can correct or complete Made and Found memories later, including metadata and photos, while preserving unchanged fields and local photo associations.

### Story 5.1: Enter Edit Mode from Memory Detail

As a FoodLife user,
I want to edit a saved memory from its detail view,
So that I can correct or complete details after the moment has passed.

**Requirements:** FR24, FR25

**Acceptance Criteria:**

**Given** I am viewing a Made or Found memory detail
**When** I choose Edit Memory
**Then** the app opens an edit flow for that same memory
**And** the edit flow preserves the memory type and uses type-specific labels
**And** the current photo and saved metadata are prefilled
**And** the return path can cancel back to the original detail view without changing the record
**And** the edit action has accessible labels and focus behavior.

### Story 5.2: Edit Made Memory Metadata

As a FoodLife user,
I want to edit dish name, ingredients, date, comfort context, and notes for a Made memory,
So that my home-cooked memories can become more accurate over time.

**Requirements:** FR24, FR26, FR27, FR28, FR44

**Acceptance Criteria:**

**Given** I am editing a Made memory
**When** I update Made metadata and save
**Then** the local record reflects the changed fields
**And** unchanged fields and existing photo references remain preserved
**And** required Made fields are validated inline and recoverably
**And** optional comfort level and note/context can be added, changed, cleared, or left unchanged
**And** updated Made metadata appears correctly in detail, Made gallery, Timeline, and Home when those surfaces use it.

### Story 5.3: Edit Found Memory Metadata

As a FoodLife user,
I want to edit restaurant, location, dining date, discovery source, first-visit marker, and notes for a Found memory,
So that dining-out memories can be corrected without losing place context.

**Requirements:** FR25, FR26, FR27, FR28, FR44

**Acceptance Criteria:**

**Given** I am editing a Found memory
**When** I update Found metadata and save
**Then** the local record reflects the changed fields
**And** unchanged fields and existing photo references remain preserved
**And** required Found fields are validated inline and recoverably
**And** optional discovery source, first-visit marker, and note/context can be added, changed, cleared, or left unchanged
**And** manual location metadata can be preserved or corrected even when map/geocoding services are unavailable.

### Story 5.4: Replace or Preserve Memory Photo

As a FoodLife user,
I want to replace a memory photo only when I explicitly choose to,
So that editing metadata does not accidentally break the visual anchor of a memory.

**Requirements:** FR26, FR27, FR28, FR44

**Acceptance Criteria:**

**Given** I am editing a Made or Found memory
**When** I save metadata changes without replacing the photo
**Then** existing photo references remain unchanged
**And** the photo remains associated with the correct memory
**And** when I explicitly replace the photo, the new photo is stored through the platform photo store boundary
**And** the memory record updates to reference the new photo metadata
**And** photo replacement failures are recoverable and do not corrupt existing metadata.

### Story 5.5: Confirm Update and Refresh Related Views

As a FoodLife user,
I want updates to be confirmed and reflected wherever the memory appears,
So that I can trust the archive after correcting a memory.

**Requirements:** FR24, FR25, FR26, FR27, FR28

**Acceptance Criteria:**

**Given** I save changes to a Made or Found memory
**When** the update succeeds
**Then** the app confirms the memory was updated locally
**And** the detail view shows the updated values
**And** relevant browse surfaces display updated metadata the next time they load or refresh
**And** saved updates remain available after app or browser restart
**And** failed updates show specific recoverable errors without implying that existing saved data was lost.

## Epic 6: Home Seasonal Reflection and Timeline Rediscovery

Users can rediscover their food life through a gentle seasonal Home recap and a chronological Timeline that combines Made and Found memories while preserving type clarity and detail navigation.

### Story 6.1: Generate Seasonal Recap from Local Memories

As a FoodLife user,
I want Home to generate a seasonal recap from my saved Made and Found memories,
So that my archive reflects my recent food life back to me.

**Requirements:** FR29, FR30, FR31, FR43

**Acceptance Criteria:**

**Given** saved Made and Found memories exist locally
**When** Home loads
**Then** the app generates a seasonal recap from local records
**And** the recap includes gentle seasonal language, photo-led presentation, and lightweight Made/Found context
**And** recap generation completes within the NFR target or runs asynchronously without blocking navigation
**And** the recap does not use charts, heavy analytics, rankings, ratings, nutrition, spending, or productivity language
**And** recap logic is covered by deterministic tests using schema-contract expected outputs where applicable.

### Story 6.2: Present Home Seasonal Reflection Experience

As a FoodLife user,
I want Home to feel like a seasonal chapter of my food life,
So that opening FoodLife creates reflective rediscovery rather than dashboard checking.

**Requirements:** FR29, FR30, FR31, FR32

**Acceptance Criteria:**

**Given** Home has recap data or recent local memories
**When** I view Home
**Then** I see a Seasonal Cover Home experience with standout imagery, reflective copy, and Made/Found previews
**And** seasonal accents are used carefully without becoming dominant backgrounds
**And** each preview exposes photo, type, title, date, and primary context
**And** selecting a preview opens the related memory detail
**And** Home uses empty or low-data states that invite capture without pressure.

### Story 6.3: Browse All Memories in Chronological Timeline

As a FoodLife user,
I want to browse Made and Found memories together in chronological order,
So that I can revisit my food life across time.

**Requirements:** FR4, FR33, FR35, FR43

**Acceptance Criteria:**

**Given** saved Made and Found memories exist locally
**When** I open Timeline
**Then** I see all memories ordered chronologically by memory date
**And** Made and Found entries remain distinguishable through labels, icons, metadata hierarchy, and accents
**And** each timeline item includes photo or missing-photo state, type, title, date, and primary metadata
**And** Timeline remains usable with at least 2,000 local memories and associated photo references
**And** Timeline does not require network connection, account, cloud sync, or backend API.

### Story 6.4: Open Memory Details from Timeline and Home

As a FoodLife user,
I want to open memory details from Home and Timeline,
So that seasonal and chronological browsing can lead back to the full memory.

**Requirements:** FR32, FR34

**Acceptance Criteria:**

**Given** Home or Timeline displays a memory preview
**When** I select that memory
**Then** the appropriate Made or Found detail view opens
**And** the detail route preserves the originating context for predictable return behavior
**And** type-specific detail labels and metadata are preserved
**And** missing photo states still allow detail navigation using text metadata
**And** navigation is keyboard accessible on web and labeled for assistive technology on iOS.

### Story 6.5: Make Home and Timeline Responsive and Accessible

As a FoodLife user,
I want Home and Timeline to work across screen sizes and accessibility modes,
So that rediscovery remains comfortable on iOS and web.

**Requirements:** FR4, FR29, FR30, FR31, FR33, FR35

**Acceptance Criteria:**

**Given** Home and Timeline are implemented
**When** they are viewed on mobile, tablet, desktop, and wide desktop web sizes
**Then** text, controls, previews, and memory metadata remain readable and non-overlapping
**And** mobile uses single-column layouts while larger screens may use richer seasonal modules and grouped chronology layouts
**And** all memory previews have accessible names including type, title, date, and primary context
**And** Made and Found distinctions do not rely on color alone
**And** responsive and accessibility checks cover empty states, loading states, fallback states, keyboard navigation, VoiceOver, text scaling, and current Safari and Chrome
**And** the verification matrix covers Home starter state, Home low-data state, Home seasonal recap state, Timeline empty state, Timeline loaded state, missing-photo timeline items, and detail navigation from Home and Timeline.
