# FoodLife Schema Contract

This package owns the canonical FoodMemory v1 contract shared by the FoodLife
web and iOS apps. Platform repositories and UI models must conform to this
package instead of becoming separate schema sources.

## Install

Run from this package:

```bash
npm install
```

## Validate

Run the schema contract test suite:

```bash
npm test
```

The `validate` script is an alias for the same contract checks:

```bash
npm run validate
```

## JSON Schema

The portable artifact lives at `schemas/food-memory-v1.schema.json` and is
generated from the Zod source in `src/food-memory-v1.ts`.

Regenerate it after schema changes:

```bash
npm run generate:schema
```

## Contract Rules

- `schemaVersion` is `1`.
- `type` is exactly `made` or `found`.
- IDs are strings.
- Date fields are ISO 8601 date-time strings.
- `photoRefs` contains local photo references only; memory records never embed
  image blobs.
- Optional fields are omitted when absent. `null` is not valid in v1.
