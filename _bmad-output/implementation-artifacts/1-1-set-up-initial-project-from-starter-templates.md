# Story 1.1: Set Up Initial Project from Starter Templates

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a FoodLife user,
I want the iOS and web apps to open into the same core product structure,
so that FoodLife feels like one coherent local-first archive across platforms.

## Acceptance Criteria

1. Given the FoodLife repository has no implementation app shells, when the workspace is initialized, then it contains `apps/ios`, `apps/web`, and `packages/schema-contract` following the architecture structure.
2. The web app is initialized from the Vite React TypeScript starter with route placeholders for Home, Made, Found, Timeline, Add Memory, and Detail/Edit.
3. The iOS app shell is initialized from the native SwiftUI Xcode app template with matching conceptual navigation placeholders.
4. The web app dependency install, initial test command, and production build command are documented and verified.
5. The iOS app build can be verified locally in Xcode, or any unavailable Xcode automation constraint is explicitly documented.
6. No backend, authentication, cloud sync, or placeholder server API is introduced.

## Tasks / Subtasks

- [ ] Create the repository app/package structure (AC: 1, 6)
  - [ ] Create `apps/ios`, `apps/web`, and `packages/schema-contract`.
  - [ ] Keep `packages/schema-contract` minimal for this story; add a README or placeholder only. Do not define FoodMemory schema fixtures yet; that is Story 1.2.
  - [ ] Do not add backend folders, API clients, auth providers, cloud sync placeholders, server deployment files, or fake remote services.
- [ ] Initialize the web shell from the official Vite React TypeScript starter (AC: 2, 4, 6)
  - [ ] Run `npm create vite@latest apps/web -- --template react-ts` from the repo root.
  - [ ] Install web dependencies from `apps/web`.
  - [ ] Add React Router, Tailwind CSS via the Vite plugin, and Vitest if the Vite starter does not include the needed test script.
  - [ ] Replace starter demo UI with a FoodLife app shell and route placeholders for `/`, `/made`, `/found`, `/timeline`, `/add`, and detail/edit placeholders such as `/memories/:memoryId` and `/memories/:memoryId/edit`.
  - [ ] Ensure route placeholder text uses the product destinations: Home, Made, Found, Timeline, Add Memory, Detail/Edit.
- [ ] Initialize the iOS shell from the native SwiftUI Xcode app template (AC: 1, 3, 5, 6)
  - [ ] Create an iOS App project named `FoodLife` under `apps/ios`.
  - [ ] Use Swift as the language and SwiftUI as the interface.
  - [ ] Include unit tests and UI tests.
  - [ ] Add a minimal SwiftUI navigation shell with conceptual placeholders for Home, Made, Found, Timeline, Add Memory, and Detail/Edit.
  - [ ] If Xcode project creation cannot be automated faithfully by CLI, document the exact Xcode template steps and verify the resulting project locally.
- [ ] Document verification commands and results (AC: 4, 5)
  - [ ] Add or update setup documentation with web install, test, and production build commands.
  - [ ] Run and record the web install command, initial test command, and production build command.
  - [ ] Run an iOS local build through Xcode or `xcodebuild` if the generated project/scheme allows it; otherwise document the Xcode automation constraint explicitly.
- [ ] Keep the shell aligned with FoodLife UX and architecture boundaries (AC: 2, 3, 6)
  - [ ] Use platform-appropriate navigation; web can use React Router, iOS should use SwiftUI-native navigation/tab patterns.
  - [ ] Make Made/Found labels visible as text, not color-only cues.
  - [ ] Avoid recipe, restaurant review, nutrition, analytics, social feed, account, or cloud language in placeholder UI.

## Dev Notes

### Current Repository State

- This is a greenfield implementation repo. At story creation time there is no existing `apps/ios`, `apps/web`, `packages/schema-contract`, root `package.json`, lockfile, Vite config, or Xcode project.
- Available local tooling at story creation time:
  - Node `v24.6.0`
  - npm `11.8.0`
  - Xcode `16.4`
  - Swift `6.1.2`
- There are no existing app files to preserve. Preserve all planning artifacts under `_bmad-output` and existing BMad/config files.

### Story Scope

- This story creates starter shells and conceptual navigation placeholders only.
- Do not implement memory persistence, schema validation, photo storage, Add Memory form behavior, Made gallery, Found map, Timeline logic, or seasonal recap generation in this story.
- Do not create backend, authentication, cloud sync, cloud photo, public sharing, server API, or server deployment placeholders.
- Do not let `packages/schema-contract` become a half-built schema package in this story. Create the package folder and lightweight README/placeholder only; Story 1.2 owns FoodMemory v1 schema, fixtures, and validation tests.

### Architecture Requirements

- FoodLife is a dual-platform local-first app: native iOS plus web SPA. Use separate starters in one repo rather than a single cross-platform runtime. [Source: `_bmad-output/planning-artifacts/architecture.md` > Primary Technology Domain]
- Web must use Vite React TypeScript. Architecture initialization command: `npm create vite@latest apps/web -- --template react-ts`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Selected Starter]
- iOS must use the native SwiftUI Xcode app template: Product Name `FoodLife`, Interface `SwiftUI`, Language `Swift`, unit tests and UI tests included, location `apps/ios`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Selected Starter]
- Repository structure must keep platform code separate:
  - `apps/ios` contains only native iOS app code.
  - `apps/web` contains only web app code.
  - `packages/schema-contract` contains canonical schema fixtures, expected outputs, and migration notes once Story 1.2 starts. [Source: `_bmad-output/planning-artifacts/architecture.md` > Project Organization]
- MVP has no backend API. Views should eventually call feature view models/hooks and service interfaces, but this starter story should not invent persistence or service implementations. [Source: `_bmad-output/planning-artifacts/architecture.md` > Architectural Boundaries]

### Web Implementation Guardrails

- Use React Router for Home, Made, Found, Timeline, Add Memory, and Detail/Edit routes. [Source: `_bmad-output/planning-artifacts/architecture.md` > Frontend Architecture]
- Prefer React Router Declarative mode for this starter shell. Data mode is acceptable if the implementation has a clear reason, but Framework mode is unnecessary because the MVP does not need SSR or server route modules. [Source: `_bmad-output/planning-artifacts/architecture.md` > Starter Options Considered]
- Use Tailwind CSS through `@tailwindcss/vite`; express FoodLife tokens as CSS/theme variables when token work begins. Do not use Tailwind v3 PostCSS setup unless a compatibility issue is documented. [Source: `_bmad-output/planning-artifacts/architecture.md` > Starter Options Considered]
- Use Vitest for the initial web test command. Keep the first test simple and meaningful: app shell renders the primary destinations or route placeholders. [Source: `_bmad-output/planning-artifacts/architecture.md` > Testing Framework]
- React components use PascalCase files. TypeScript non-component files use kebab-case. [Source: `_bmad-output/planning-artifacts/architecture.md` > Code Naming Conventions]

### iOS Implementation Guardrails

- Use SwiftUI-native navigation and platform conventions. Placeholder destinations should map conceptually to Home, Made, Found, Timeline, Add Memory, and Detail/Edit. [Source: `_bmad-output/planning-artifacts/architecture.md` > Frontend Architecture]
- Keep Swift files PascalCase. If adding starter organization beyond the Xcode template, align with future folders such as `FoodLife/App`, `FoodLife/Features/Home`, `FoodLife/Features/Made`, `FoodLife/Features/Found`, `FoodLife/Features/Timeline`, `FoodLife/Features/AddMemory`, and `FoodLife/Features/DetailEdit`. [Source: `_bmad-output/planning-artifacts/architecture.md` > Unified Project Structure]
- Do not introduce SwiftData models in this story unless the Xcode template requires none; domain and persistence contracts begin in later Epic 1 stories.
- If project creation is manual through Xcode, the dev agent must document the exact Xcode choices and the local build result in completion notes.

### UX Requirements for Placeholders

- The product must expose the six conceptual destinations: Home, Made, Found, Timeline, Add Memory, and Detail View across iOS and web. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` > Platform Experience Strategy]
- Preserve the Made / Found emotional split from the start. Placeholder labels should make clear that Made means food the user cooked and Found means food or places discovered outside. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` > Core UX Principles]
- Made/Found distinction must not rely on color alone; use labels and structure even in placeholders. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` > Accessibility & Inclusive Design]
- Keep placeholder UI photo-first/product-oriented without adding social feed, rating, nutrition, recipe-builder, or analytics concepts. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` > Anti-Patterns to Avoid]
- Use the Porcelain & Market Green palette only as a starter token foundation if styling is added: background `#F7F5F0`, surface `#FFFFFF`, text `#24221F`, Made `#C1A79C`, Found `#7CB342`, Seasonal `#B9A36A`, Accent `#1E9E8A`, Muted `#7B7770`. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md` > Visual Design Foundation]

### Latest Technical Notes

- Vite's official docs list `react-ts` as a supported create-vite template. Use that starter for `apps/web`. [Source: https://vite.dev/guide/]
- Tailwind CSS current Vite installation uses `tailwindcss` plus `@tailwindcss/vite`, the Vite plugin in `vite.config.ts`, and `@import "tailwindcss";` in CSS. [Source: https://tailwindcss.com/docs/installation/using-vite]
- React Router currently offers Declarative, Data, and Framework modes. For this SPA starter, Declarative mode gives URL matching, navigation, and active states without adopting server/framework conventions. [Source: https://reactrouter.com/start/modes]
- Vitest is Vite-native, reads Vite config by default, and current docs state it requires Vite `>=6.0.0` and Node `>=20.0.0`. Local Node `v24.6.0` satisfies this. Use `vitest run` for a one-shot CI-style test command. [Source: https://vitest.dev/guide/]

### Suggested Verification Commands

Run from repo root unless noted.

```bash
cd apps/web
npm install
npm run test -- --run
npm run build
```

If scripts differ after scaffold/configuration, document the actual commands in the story completion notes.

For iOS, prefer a local Xcode build. If the scheme is visible to `xcodebuild`, a command may look like:

```bash
xcodebuild -project apps/ios/FoodLife.xcodeproj -scheme FoodLife -destination 'platform=iOS Simulator,name=iPhone 16' build
```

If no matching simulator is installed or Xcode automation cannot run in the environment, document that limitation and verify through Xcode UI if available.

### Project Structure Notes

- Expected high-level result:

```text
apps/
  ios/
  web/
packages/
  schema-contract/
```

- Web starter files should remain under `apps/web`; do not move Vite config or web `package.json` to the repo root unless a deliberate workspace decision is documented.
- iOS Xcode project files should remain under `apps/ios`.
- User runtime photos are not committed assets. Starter placeholder assets should be ordinary app assets only.

### Git Intelligence

- Recent commits show planning artifacts only, not implementation code:
  - `cd2a614 Add sprint tracking artifacts`
  - `1533e15 Apply readiness cleanup to epics`
  - `342e082 Add implementation readiness planning artifacts`
  - `9c2f2e7 Add FoodLife epics and stories`
  - `5602373 Add FoodLife architecture`
- There are no prior code conventions beyond the documented architecture.

### References

- `_bmad-output/planning-artifacts/epics.md` > Story 1.1
- `_bmad-output/planning-artifacts/prd.md` > Executive Summary, Product Scope, Technical Success
- `_bmad-output/planning-artifacts/architecture.md` > Selected Starter, Frontend Architecture, Project Organization, Unified Project Structure, Architectural Boundaries
- `_bmad-output/planning-artifacts/ux-design-specification.md` > Platform Experience Strategy, Core UX Principles, Visual Design Foundation, Accessibility & Inclusive Design
- https://vite.dev/guide/
- https://tailwindcss.com/docs/installation/using-vite
- https://reactrouter.com/start/modes
- https://vitest.dev/guide/

## Dev Agent Record

### Agent Model Used

TBD by dev agent.

### Debug Log References

TBD by dev agent.

### Completion Notes List

- Story context created on 2026-05-03.
- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List

TBD by dev agent.
