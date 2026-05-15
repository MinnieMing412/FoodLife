# FoodLife

Fresh project workspace for FoodLife.

## Status

Initial iOS, web, and schema-contract foundation is in place, including the
baseline GitHub Actions test workflow.

## Project Structure

```text
apps/
  ios/
  web/
packages/
  schema-contract/
```

`apps/web` contains the Vite React TypeScript web shell. `apps/ios` contains
the native SwiftUI app shell. `packages/schema-contract` contains the shared
FoodMemory v1 schema contract, fixtures, generated JSON Schema, expected
conformance outputs, and validation tests.

## Web Setup

Run web commands from `apps/web`.

```bash
npm install
npm run test
npm run lint
npm run build
```

`npm run build` runs the TypeScript build check before the Vite production
build.

Verified on 2026-05-14:

- `npm install` completed with 0 vulnerabilities.
- `npm run test` completed with passing Vitest tests.
- `npm run lint` completed successfully.
- `npm run build` completed successfully.

## Schema Contract Setup

Run schema contract commands from `packages/schema-contract`.

```bash
npm install
npm test
npm run validate
npm run generate:schema
```

The `validate` script runs the same contract checks as `npm test`. After
regenerating the portable JSON Schema artifact, verify that
`schemas/food-memory-v1.schema.json` has no unexpected diff.

## iOS Setup

The iOS shell is a SwiftUI app project named `FoodLife` under `apps/ios`, with SwiftUI interface, Swift language, unit tests, and UI tests.

To verify from the command line:

```bash
xcodebuild -project apps/ios/FoodLife.xcodeproj -scheme FoodLife -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project apps/ios/FoodLife.xcodeproj -scheme FoodLife -destination 'generic/platform=iOS Simulator' -derivedDataPath .build/DerivedData CODE_SIGNING_ALLOWED=NO build-for-testing
```

The GitHub Actions `Test Suite` workflow also runs an iOS build-for-testing and
unit-test pass on `macos-latest` using an available iPhone simulator.

Verified on 2026-05-04:

- `xcodebuild -project apps/ios/FoodLife.xcodeproj -list` shows the `FoodLife`, `FoodLifeTests`, and `FoodLifeUITests` targets and the `FoodLife` scheme.
- `xcodebuild ... build` succeeded.
- `xcodebuild ... build-for-testing` succeeded.
- Simulator runtime execution is constrained in the Codex sandbox because `CoreSimulatorService` is unavailable there; open the project in Xcode to run the UI test on a local simulator.

If recreating the project from Xcode UI, use the native template: iOS App, Product Name `FoodLife`, Interface `SwiftUI`, Language `Swift`, include unit tests and UI tests, and save it under `apps/ios`.

## CI Verification

The repository uses `.github/workflows/test-suite.yml` for baseline validation.
It runs on pushes to `main`, `codex/**`, `dev-*`, `dev/**`, and `feature/**`,
and can also be started manually with `workflow_dispatch`.

The workflow keeps repository permissions read-only and runs:

- Web install, tests, lint, and production build from `apps/web`
- Schema-contract install, tests, validation, and generated JSON Schema
  freshness checks from `packages/schema-contract`
- iOS build-for-testing and unit tests from `apps/ios` on a GitHub-hosted macOS
  runner

## Planning

BMad is installed in this repository and should be used for product planning, architecture, and implementation workflow artifacts.

Recommended first step:

```text
bmad-create-prd
```

Use BMad outputs under `_bmad-output/` when new planning artifacts are generated.
