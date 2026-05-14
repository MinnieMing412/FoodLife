import { writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { generatedFoodMemoryV1JsonSchema } from "./food-memory-v1.ts";

const schemaPath = resolve(import.meta.dirname, "..", "schemas", "food-memory-v1.schema.json");

writeFileSync(schemaPath, `${JSON.stringify(generatedFoodMemoryV1JsonSchema, null, 2)}\n`);
