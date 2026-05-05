---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-02b-vision
  - step-02c-executive-summary
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
  - step-12-complete
  - step-e-01-discovery
  - step-e-02-review
  - step-e-03-edit
date: '2026-05-02'
releaseMode: phased
inputDocuments:
  - /Users/yimingli/workspace/my_projects/FoodLife/_bmad-output/brainstorming/brainstorming-session-2026-05-01-0000.md
documentCounts:
  productBriefs: 0
  research: 0
  brainstorming: 1
  projectDocs: 0
classification:
  projectType: mobile_app + web_app
  domain: general consumer lifestyle / personal memory archive
  complexity: low
  projectContext: greenfield
workflowType: 'prd'
lastEdited: '2026-05-02'
editHistory:
  - date: '2026-05-02'
    changes: 'Addressed validation findings: measurable NFRs, mobile/web compliance detail, FR exclusion cleanup, and frontmatter date metadata.'
  - date: '2026-05-02'
    changes: 'Added validation-driven handoff guidance for architecture, UX specifications, and scope-change maintenance.'
---

# Product Requirements Document - FoodLife

**Author:** yiming
**Date:** 2026-05-02

## Executive Summary

FoodLife is a private, photo-first food lifestyle archive for documenting food the user made at home and food they found while dining out. The product helps a single user preserve food memories with lightweight context, then browse those memories through four core views: Home, Made, Found, and Timeline.

The v1 product is a full iOS app and full web app built around a shared local-first data model. It focuses on capturing and revisiting personal food memories, not publishing content, tracking nutrition, reviewing restaurants, or managing recipes. The primary user value is emotional recall: remembering what was cooked, where food was discovered, when it happened, and what made the memory meaningful.

### What Makes This Special

FoodLife's core product distinction is the Made / Found structure. Made represents home-cooked food as comfort, authorship, ingredients, and warmth. Found represents dining-out memories as happiness, place discovery, restaurant context, and personal exploration. These two memory types share a common archive model but use different visual moods and browsing metaphors.

The product replaces common food-app patterns with memory-first alternatives: ratings become personal discovery notes, recipes become ingredient memories, dashboards become seasonal reflection, and restaurant search becomes a personal map of places already found. Over time, the app becomes more valuable by reflecting the user's food life back through seasonal chapters, a warm Made gallery, a bright Found map, and a combined chronological Timeline.

## Experience Principles

FoodLife must preserve the emotional split between Made and Found throughout the product. Made should feel warm, calm, personal, and home-oriented. Found should feel brighter, happier, discovery-oriented, and place-aware.

The interface should stay photo-led. Metadata supports the memory but should not dominate browsing or capture. Forms should feel like memory capture, not administration.

Home should present gentle seasonal reflection, not analytics. Recaps should use human language, photos, and lightweight counts only when they reinforce the memory experience.

The UX design workflow should translate these principles into screen-level patterns for Home, Made, Found, Timeline, Add Memory, and Detail View. UX specifications should define Made/Found mood differences, responsive behavior, accessibility treatments, and photo-led hierarchy without adding social, rating, nutrition, or analytics patterns.

## Project Classification

FoodLife is a greenfield, cross-platform personal application with an iOS app and a full web app. The domain is general consumer lifestyle and personal memory archiving. Domain complexity is low because the MVP avoids regulated workflows, public social networking, payments, authentication, cloud sync, restaurant marketplace features, nutrition tracking, and heavy analytics.

## Success Criteria

### User Success

FoodLife succeeds for the user when they can quickly capture a food memory, classify it as Made or Found, attach the right lightweight context, and later rediscover that memory through the appropriate browsing mode. A Made memory should feel like preserving home comfort, ingredients, and self-made food. A Found memory should feel like preserving dining-out happiness, restaurant context, and place discovery.

The first strong user success moment is creating a memory without feeling like they are filling out a database. The long-term success moment is opening the app after weeks or months and seeing a meaningful seasonal reflection of their food life.

### Business Success

The MVP succeeds if it validates FoodLife as a private food-life archive rather than a recipe app, restaurant review app, nutrition tracker, or social network. Success means the core product spine is clear enough that all major features map cleanly to Home, Made, Found, Timeline, Add Memory, or Detail View.

The product should prove that a single-user/local-first version is valuable before adding account systems, cloud sync, sharing, restaurant search, or marketplace-style discovery.

### Technical Success

The MVP must use one shared FoodMemory schema and a storage abstraction that supports both iOS and web implementations. Local data and local photo storage must work reliably in v1 while keeping the architecture portable enough for future cloud sync and cloud photo storage.

The technical foundation succeeds if Made and Found memories share common underlying structure without forcing identical user experiences. The app must support photo-first capture, type-specific metadata, local persistence, local photo retrieval, and chronological browsing.

### Measurable Outcomes

- A user can create a Made memory with photo, dish name, ingredients, date, optional comfort level, and optional note fields.
- A user can create a Found memory with photo, restaurant, location, dining date, optional discovery source, and optional note fields.
- A user can browse Made memories in a gallery-first view.
- A user can browse Found memories in a map-first view.
- A user can browse all memories together in a chronological Timeline.
- Home can generate a simple seasonal recap from local records.
- The MVP excludes authentication, cloud sync, public social feed, restaurant search, full recipes, and heavy analytics.

## Product Scope

### MVP - Minimum Viable Product

The MVP includes a full iOS app and full web app for a single local-first user. Core navigation is Home, Made, Found, and Timeline. The product includes a global Add Memory flow that starts with Made or Found, then captures a photo and type-specific details. Made includes a gallery-first browsing experience. Found includes a map-first browsing experience. Timeline combines Made and Found memories chronologically. Home shows a simple seasonal recap.

### Growth Features (Post-MVP)

Post-MVP growth can add richer filtering, memory pairing, neighborhood or trip clusters, "this time last year," enhanced seasonal recaps, stronger photo presentation, and optional inspiration flows based on the user's own Made and Found memories.

### Vision (Future)

The long-term vision is a durable personal food-life archive that becomes more meaningful over years of use. Future versions may add cloud sync, cloud photo storage, multi-device continuity, richer seasonal chapters, and selective sharing while preserving the product's private, memory-first character.

## User Journeys

### Journey 1: Capturing a Made Memory

The user has just cooked a dish they like at home. The moment feels warm and personal: the food is not just a meal, it is something they made by hand and want to remember. They open FoodLife, tap the global add control, and choose Made before doing anything else.

The app asks for the photo first. After selecting or taking the photo, the user adds a dish name, ingredients, date, and optional note. The form stays lightweight and does not ask for recipe steps, cooking time, servings, nutrition, or meal-planning data. The user saves the memory and sees it appear in the Made gallery.

The value moment is immediate: the entry feels like a preserved food memory rather than a recipe record. Later, tapping the photo reveals the ingredient context and note behind the dish.

This journey reveals requirements for Made memory creation, photo-first capture, type-specific fields, local photo storage, local persistence, and gallery browsing.

### Journey 2: Capturing a Found Memory

The user has eaten something memorable at a restaurant or cafe. The feeling is happy and discovery-oriented: they found a place worth remembering. They open FoodLife, tap add, and choose Found.

The app asks for the food photo first, then captures restaurant name, location, dining date, and optional context such as how the place was found, whether it was a first visit, and a short note. The product does not ask for a star rating, public review, price analysis, or restaurant recommendation.

After saving, the memory appears on the Found map. The map is personal and photo-led: the restaurant is remembered as part of the user's food life, not treated as a listing in a review database.

This journey reveals requirements for Found memory creation, location capture, restaurant metadata, optional discovery fields, local persistence, map display, and photo-led place browsing.

### Journey 3: Rediscovering Food Life Through Home and Timeline

After several weeks or months of use, the user opens FoodLife without a specific memory in mind. They want to revisit what they have been making and finding lately. Home presents a simple seasonal recap built from local records, with language and imagery that feel reflective rather than analytical.

The user sees a seasonal chapter containing recent Made and Found memories. The recap uses human language and photos rather than heavy charts. From there, they can enter Timeline to browse everything chronologically. Timeline helps them see continuity: comfort meals at home, dining discoveries outside, and how those memories changed over time.

The value moment is long-term: FoodLife becomes more meaningful because it reflects life back through time, rather than only storing isolated entries.

This journey reveals requirements for seasonal grouping, Home recap generation, mixed Made/Found display, chronological sorting, date metadata, and navigation between Home, Timeline, and memory details.

### Journey 4: Correcting or Completing a Memory Later

The user saves a memory quickly and later realizes something is missing or wrong: an ingredient was forgotten, the restaurant name needs correction, the location was incomplete, or the date should be adjusted. They open the memory detail view and edit the fields without friction.

For Made, they can revise dish name, ingredients, date, comfort context, and notes. For Found, they can revise restaurant, location, dining date, discovery context, first-visit marker, and notes. The app preserves the photo and avoids making edits feel like administrative cleanup.

The recovery moment is important: the user trusts the archive because memories can be corrected as details come back.

This journey reveals requirements for memory detail views, editing existing memories, validation that does not block lightweight capture, save/update behavior, and reliable local data persistence.

### Journey Requirements Summary

The journeys reveal six core capability areas for MVP:

- Type-first Add Memory flow with Made and Found paths.
- Photo-first capture with local photo storage.
- Type-specific metadata for Made and Found memories.
- Local-first memory persistence with edit support.
- Browsing surfaces: Made gallery, Found map, Home seasonal recap, and Timeline.
- Memory detail views that reveal lightweight context behind each photo.

The journeys also confirm excluded MVP behavior: public sharing, followers, ratings, restaurant search, full recipe management, nutrition tracking, analytics dashboards, accounts, and cloud sync are not required for the first version.

## Mobile and Web App Specific Requirements

### Project-Type Overview

FoodLife v1 is a cross-platform personal application consisting of a native iOS app and a full web app. Both platforms must support the complete core experience: create, edit, browse, and revisit Made and Found memories. The web app is not a read-only companion.

The iOS app should be Swift-first and optimized for personal capture on the user's device. The web app should be a browser-based SPA that supports the same product model and core workflows. Both platforms must use the same FoodMemory schema and align around a shared storage abstraction so local-first v1 does not create a dead-end architecture.

### Technical Architecture Considerations

The product must be designed around a shared data model for Made and Found memories. The storage layer should expose a consistent interface for create, read, update, delete, photo retrieval, timeline sorting, seasonal grouping, and map-related location retrieval. The implementation can differ by platform, but the behavior and data contract should remain consistent.

FoodLife v1 is local-first. The app should support create, edit, browse, photo access, map display, and timeline browsing from local data. The architecture should preserve a future migration path to cloud sync and cloud photo storage without requiring a redesign of the memory schema.

### Platform Requirements

The iOS app must support current iPhone usage patterns for photo-first capture and browsing. It should prioritize fast add flow access, native photo selection, camera capture, local storage reliability, smooth gallery browsing, and map interaction.

The web app must support current Safari and Chrome. It should provide full create, edit, and browse workflows for Home, Made, Found, Timeline, Add Memory, and Detail View. The web app must support mobile, tablet, and desktop viewport classes, but native iOS remains the primary mobile-device experience.

### Device Permissions and Capabilities

The iOS app should request only permissions needed for the MVP experience:

- Camera access for taking food photos.
- Photo library access for selecting existing food photos.
- Location access for Found memories and map placement.

Push notifications are excluded from MVP. The app should avoid requesting background location or other sensitive permissions unless a later feature explicitly requires them.

### iOS Store and Privacy Compliance

The iOS app must be prepared for App Store distribution requirements that apply to personal photo and location apps. Permission prompts and privacy disclosures must explain camera, photo library, and location usage in FoodLife terms. App Store privacy metadata must reflect local photo, location, and memory data handling accurately.

The MVP must not request account, tracking, background location, notification, contacts, health, payment, or advertising permissions. Any future capability that changes permission scope must update privacy disclosures and product requirements before implementation.

### Offline and Local-First Behavior

The MVP should allow the user to create, edit, and browse local memories without requiring an account, network connection, or cloud service. Photos and metadata must remain available locally after save. Timeline, Made gallery, and Home recap should be generated from local records.

Found map behavior should use locally stored memory locations. If map tiles or geocoding require network access, the app should degrade gracefully by preserving the saved memory and location metadata even when external map services are unavailable.

### Web App Requirements

The web app should be implemented as a full browser SPA. It must support the same conceptual navigation as iOS: Home, Made, Found, Timeline, Add Memory, and Detail View. Browser storage and local photo handling should be designed carefully so the web version can serve as a complete local-first archive within realistic browser constraints.

The web app must support these viewport classes: mobile narrow screens, tablet screens, desktop screens, and wide desktop screens. Core workflows must preserve readable text, reachable controls, and non-overlapping memory content across these viewport classes.

The MVP does not require SEO-focused public pages, server-rendered marketing pages, user accounts, collaboration, or public sharing.

### Accessibility Targets

The web app should target WCAG 2.2 AA for core create, edit, browse, and detail workflows. The iOS app should support platform accessibility features for the same workflows, including readable text scaling, accessibility labels for actionable controls, and non-color-only Made/Found distinctions.

### Implementation Considerations

FoodLife should keep platform-specific implementation details behind a shared product model. The most important technical decision is the shared FoodMemory schema and storage abstraction, because future cloud sync depends on avoiding divergent iOS and web data models.

The MVP should prioritize reliability over infrastructure breadth: local save behavior, photo persistence, edit behavior, and timeline/map/gallery retrieval must be dependable before adding cloud services or sharing features.

The architecture workflow should resolve concrete decisions for local metadata storage, local photo references, map and geocoding fallback behavior, schema conformance tests, and future cloud migration boundaries. Those decisions must preserve the product requirements in this PRD without turning the PRD into a platform implementation spec.

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Experience MVP. FoodLife v1 must prove that the Made / Found memory model creates a valuable private food-life archive before the product adds cloud, social, or marketplace features.

**Resource Requirements:** MVP delivery requires iOS development, web development, shared data-model/storage design, product design for the Made/Found visual split, and basic QA across local persistence, photo handling, map behavior, and timeline/recap generation.

The MVP should optimize for validating the core emotional experience: fast photo-first capture, clear Made/Found classification, and meaningful rediscovery through gallery, map, timeline, and seasonal recap.

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**

- Capturing a Made memory.
- Capturing a Found memory.
- Rediscovering food life through Home and Timeline.
- Correcting or completing a memory later.

**Must-Have Capabilities:**

- Full native iOS app.
- Full browser-based web app.
- Single-user local-first operation.
- Shared FoodMemory schema and storage abstraction.
- Local metadata persistence.
- Local photo storage and retrieval.
- Home / Made / Found / Timeline navigation.
- Global Add Memory flow that starts with Made or Found.
- Made memory creation with photo, dish name, ingredients, date, optional comfort level, and optional note/context.
- Found memory creation with photo, restaurant, location, dining date, optional discovery source, optional first-visit marker, and optional note/context.
- Memory detail view for both Made and Found entries.
- Edit support for existing memories.
- Made gallery-first browsing.
- Found map-first browsing using stored location metadata.
- Timeline combining Made and Found memories chronologically.
- Simple seasonal Home recap generated from local records.
- Graceful degradation when map tiles or geocoding are unavailable.

### Post-MVP Features

**Phase 2 (Post-MVP):**

- Richer Made filtering by ingredient, comfort level, season, or date.
- Richer Found filtering by first visit, discovery source, neighborhood, or date.
- Memory pairing between related Made and Found entries.
- Neighborhood, trip, or cluster groupings for Found memories.
- "This time last year" resurfacing.
- Enhanced seasonal recaps with stronger photo selection and chapter presentation.
- Seasonal cover photo selection.
- Photo-led map pins or previews for Found memories.
- Inspiration flows based on the user's own previous memories.

**Phase 3 (Expansion):**

- Cloud sync.
- Cloud photo storage.
- Multi-device continuity.
- Optional selective sharing.
- More advanced seasonal chapters.
- Future account/authentication model if cloud or sharing features require it.

### Explicitly Out of MVP

- Authentication.
- Cloud sync.
- Cloud photo storage.
- Public social feed.
- Followers, likes, or public engagement mechanics.
- Restaurant search or Yelp-like discovery.
- Star ratings and review publishing.
- Full recipe builder or step-by-step recipe management.
- Nutrition, calorie, spending, or quantified analytics dashboards.
- Push notifications.

### Risk Mitigation Strategy

**Technical Risks:** The highest technical risks are local photo persistence, browser storage limitations, map behavior without backend services, and keeping iOS/web data models aligned. Mitigate these by defining the FoodMemory schema and storage abstraction early, testing local persistence before building advanced UI, and treating map/geocoding dependencies as replaceable services.

**Market Risks:** The main market risk is whether a private memory archive feels valuable enough without social, sync, or recommendation loops. Mitigate this by making the MVP's emotional payoff visible quickly: photo-first capture, beautiful Made/Found browsing, and a Home recap that reflects the user's food life after only a small number of memories.

**Resource Risks:** Building full iOS and full web in v1 increases implementation load. If resources tighten, preserve the shared schema and all core user journeys, but simplify visual polish, advanced filters, and recap richness before cutting Made, Found, Timeline, or Add Memory.

### Scope Change Control

Any scope change that adds accounts, cloud sync, cloud photo storage, sharing, notifications, tracking, payments, public pages, or expanded location behavior must update this PRD before implementation. Required updates include affected FRs, NFR thresholds, viewport expectations, permission assumptions, privacy disclosures, and architecture handoff requirements.

## Functional Requirements

### Memory Type Model

- FR1: Users can classify each food memory as either Made or Found.
- FR2: Users can create Made and Found memories using a shared underlying memory model.
- FR3: Users can view Made and Found memories through type-specific experiences.
- FR4: Users can distinguish Made and Found memories in combined views.

### Add Memory and Capture

- FR5: Users can start a global Add Memory flow from the app's primary navigation.
- FR6: Users can choose Made or Found before entering memory details.
- FR7: Users can attach a food photo to a new memory.
- FR8: Users can create a memory from a newly captured photo.
- FR9: Users can create a memory from an existing photo.
- FR10: Users can save a memory with only the required fields for that memory type.
- FR11: Users can add optional notes or context without blocking memory creation.

### Made Memories

- FR12: Users can create a Made memory with photo, dish name, ingredients, and date.
- FR13: Users can add optional comfort level and personal context to a Made memory.
- FR14: Users can view Made memories in a gallery-first browsing experience.
- FR15: Users can open a Made memory detail view.
- FR16: Users can view the photo, dish name, ingredients, date, and optional context for a Made memory.

### Found Memories

- FR17: Users can create a Found memory with photo, restaurant, location, and dining date.
- FR18: Users can add optional discovery source and discovery context to a Found memory.
- FR19: Users can mark whether a Found memory was a first visit.
- FR20: Users can view Found memories in a map-first browsing experience.
- FR21: Users can open a Found memory detail view.
- FR22: Users can view the photo, restaurant, location, dining date, and optional context for a Found memory.
- FR23: Users can browse Found memories using saved location metadata.

### Memory Management

- FR24: Users can edit an existing Made memory.
- FR25: Users can edit an existing Found memory.
- FR26: Users can update memory photos and metadata after creation.
- FR27: Users can preserve saved memories locally.
- FR28: Users can retrieve saved memories locally across app sessions.

### Home and Seasonal Reflection

- FR29: Users can view a Home experience that reflects their recent food memories through gentle seasonal language and photo-led presentation.
- FR30: Users can view a seasonal recap generated from saved Made and Found memories.
- FR31: Users can see Made and Found memories together in seasonal context.
- FR32: Users can navigate from Home recap content to related memory details.

### Timeline

- FR33: Users can view all Made and Found memories together in a chronological Timeline.
- FR34: Users can open memory details from Timeline.
- FR35: Users can distinguish memory type while browsing Timeline.

### Platform Coverage

- FR36: Users can complete core create, edit, browse, and detail workflows in the iOS app.
- FR37: Users can complete core create, edit, browse, and detail workflows in the web app.
- FR38: Users can access the same conceptual product structure on iOS and web.
- FR39: The system can represent memories using a shared FoodMemory schema across platforms.
- FR40: The system can support platform-specific storage implementations behind a consistent storage abstraction.

### Local-First Operation

- FR41: Users can use FoodLife without creating an account.
- FR42: Users can create and edit local memories without cloud sync.
- FR43: Users can browse local memories without cloud sync.
- FR44: Users can access locally stored photos associated with saved memories.
- FR45: The system can preserve memory metadata when map services or geocoding are unavailable.

## Non-Functional Requirements

### Performance

- NFR1: Core local navigation between Home, Made, Found, Timeline, and memory detail views must render already-stored local data within 500 ms for a local archive of 2,000 memories on supported devices, measured in platform performance tests.
- NFR2: Creating or updating a memory must require no more than four required user-entered metadata fields after photo selection for each memory type, measured by form requirements review.
- NFR3: Made gallery and Timeline views must remain usable with at least 2,000 memories and associated local photo references, measured by platform tests for scrolling, opening details, and chronological ordering.
- NFR4: Home seasonal recap generation must complete within 1 second for an archive of 2,000 memories or run asynchronously without blocking navigation, measured by local performance tests.
- NFR5: Found map browsing must preserve saved memory cards and location metadata when map tiles or geocoding are unavailable, measured by offline or failed-service test scenarios.

### Privacy and Security

- NFR6: FoodLife v1 must not require account creation, authentication, or cloud sync.
- NFR7: FoodLife v1 must store personal food memories and photos locally by default.
- NFR8: The app must request only MVP-required permissions: camera, photo library, and location.
- NFR9: The app must explain permission use in product context before or during permission requests.
- NFR10: The MVP must not expose memories publicly or create social visibility by default.
- NFR11: If future sync or sharing is added, it must not require changing the core FoodMemory schema.

### Reliability and Data Integrity

- NFR12: Saved memories must remain available after app restart and device/browser restart in supported local storage environments, measured by persistence tests.
- NFR13: Saved photos must remain associated with the correct memory record across create, edit, detail, gallery, timeline, and map workflows, measured by regression tests.
- NFR14: Editing a memory must preserve unchanged fields and photo references unless the user explicitly modifies them, measured by update-flow tests.
- NFR15: Failed or unavailable map/geocoding services must not prevent saving a Found memory with manually entered restaurant and location metadata, measured by failed-service tests.
- NFR16: iOS and web implementations must pass the same FoodMemory schema conformance cases for Made and Found records before MVP release.

### Accessibility

- NFR17: Web core create, edit, browse, and detail workflows must target WCAG 2.2 AA; iOS equivalents must support platform accessibility labels, readable text scaling, and accessible control focus, measured by accessibility review.
- NFR18: Text, controls, and memory metadata must remain readable and non-overlapping across mobile, tablet, desktop, and wide desktop viewport classes, measured by responsive layout review.
- NFR19: Food photos must not be the only way to identify a memory; dish, restaurant, date, or location text metadata must remain available in browsing and detail contexts, measured by UX review.
- NFR20: Visual mood differences between Made and Found must not rely on color alone; labels, structure, or iconography must also communicate type, measured by accessibility review.

### Portability and Future Cloud Readiness

- NFR21: The FoodMemory schema must represent Made and Found records without platform-only required fields, verified by shared schema review before implementation.
- NFR22: Photo references must be modeled separately from memory metadata so local photo storage in v1 can be replaced by cloud photo storage later without redefining memory records, verified by architecture review.
- NFR23: Platform-specific storage implementations must support the same create, read, update, delete, list, detail, timeline, seasonal grouping, and location-retrieval behavior contract, verified by shared conformance tests.
- NFR24: MVP architecture must document a migration path for future multi-device continuity before implementation begins, verified during architecture review.
- NFR25: Scope changes that alter platform coverage, permissions, data storage, sync, sharing, public visibility, location behavior, or browser support must trigger PRD review of FRs, NFR thresholds, viewport targets, permission assumptions, privacy disclosures, and architecture handoff requirements before implementation.
