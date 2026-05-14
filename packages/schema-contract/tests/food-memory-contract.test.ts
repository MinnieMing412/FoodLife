import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";
import {
  foodMemoryV1Schema,
  generatedFoodMemoryV1JsonSchema,
} from "../src/food-memory-v1.ts";

const fixture = <T = unknown>(path: string): T =>
  JSON.parse(readFileSync(resolve(import.meta.dirname, "..", path), "utf8"));

const validationIssues = (value: unknown): string[] => {
  const result = foodMemoryV1Schema.safeParse(value);

  if (result.success) {
    return [];
  }

  return result.error.issues.map((issue) => `${issue.path.join(".")}: ${issue.message}`);
};

describe("FoodMemory v1 contract", () => {
  it("validates Made and Found fixture records", () => {
    expect(foodMemoryV1Schema.safeParse(fixture("fixtures/made-memory.valid.json")).success).toBe(
      true,
    );
    expect(foodMemoryV1Schema.safeParse(fixture("fixtures/found-memory.valid.json")).success).toBe(
      true,
    );
  });

  it.each([
    ["unsupported type", "fixtures/invalid/unsupported-type.invalid.json", "type"],
    ["missing shared field", "fixtures/invalid/missing-required-shared.invalid.json", "title"],
    ["malformed date", "fixtures/invalid/malformed-date.invalid.json", "memoryDate"],
    ["missing Made field", "fixtures/invalid/missing-made-field.invalid.json", "dishName"],
    ["missing Found field", "fixtures/invalid/missing-found-field.invalid.json", "restaurantName"],
    ["embedded photo data", "fixtures/invalid/embedded-photo-data.invalid.json", "imageBlob"],
  ])("rejects %s fixture for the intended field", (_label, fixturePath, expectedField) => {
    expect(validationIssues(fixture(fixturePath))).toEqual(
      expect.arrayContaining([expect.stringContaining(expectedField)]),
    );
  });

  it("keeps the portable JSON Schema artifact synced with the Zod source", () => {
    const artifact = fixture("schemas/food-memory-v1.schema.json");

    expect(artifact).toEqual(generatedFoodMemoryV1JsonSchema);
  });

  it("prefers omitted optional fields and rejects null optional values", () => {
    const madeMemory = fixture<Record<string, unknown>>("fixtures/made-memory.valid.json");

    expect(foodMemoryV1Schema.safeParse({ ...madeMemory, note: null }).success).toBe(false);
    expect(foodMemoryV1Schema.safeParse({ ...madeMemory, madeContext: null }).success).toBe(false);
  });
});
