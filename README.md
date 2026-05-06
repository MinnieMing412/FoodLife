# FoodLife

Fresh project workspace for FoodLife.

## Status

Initial iOS, web, and schema-contract starter structure is in place.

## Project Structure

```text
apps/
  ios/
  web/
packages/
  schema-contract/
```

`apps/web` contains the Vite React TypeScript web shell. `apps/ios` contains the native SwiftUI app shell. `packages/schema-contract` is reserved for the shared FoodMemory schema contract and intentionally remains a placeholder until Story 1.2.

## Web Setup

Run web commands from `apps/web`.

```bash
npm install
npm run test
npm run build
```

Verified on 2026-05-04:

- `npm install` completed with 0 vulnerabilities.
- `npm run test` completed with 2 passing Vitest tests.
- `npm run build` is the production build command for the Vite shell.

## iOS Setup

The iOS shell is a SwiftUI app project named `FoodLife` under `apps/ios`, with SwiftUI interface, Swift language, unit tests, and UI tests.

To verify from the command line:

```bash
xcodebuild -project apps/ios/FoodLife.xcodeproj -scheme FoodLife -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project apps/ios/FoodLife.xcodeproj -scheme FoodLife -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build-for-testing
```

Verified on 2026-05-04:

- `xcodebuild -project apps/ios/FoodLife.xcodeproj -list` shows the `FoodLife`, `FoodLifeTests`, and `FoodLifeUITests` targets and the `FoodLife` scheme.
- `xcodebuild ... build` succeeded.
- `xcodebuild ... build-for-testing` succeeded.
- Simulator runtime execution is constrained in the Codex sandbox because `CoreSimulatorService` is unavailable there; open the project in Xcode to run the UI test on a local simulator.

If recreating the project from Xcode UI, use the native template: iOS App, Product Name `FoodLife`, Interface `SwiftUI`, Language `Swift`, include unit tests and UI tests, and save it under `apps/ios`.

## Planning

BMad is installed in this repository and should be used for product planning, architecture, and implementation workflow artifacts.

Recommended first step:

```text
bmad-create-prd
```

Use BMad outputs under `_bmad-output/` when new planning artifacts are generated.
