import * as z from "zod";

const isoDateTimeString = z
  .string()
  .refine((value) => /^\d{4}-\d{2}-\d{2}T/.test(value) && !Number.isNaN(Date.parse(value)), {
    message: "must be an ISO 8601 date-time string",
  });

const photoRefV1Schema = z
  .object({
    id: z.string().min(1),
    storageKind: z.enum(["iosLocalFile", "webOpfs", "webIndexedDbBlob"]),
    localKey: z.string().min(1),
    createdAt: isoDateTimeString,
    thumbnailKey: z.string().min(1).optional(),
  })
  .strict();

const commonFoodMemoryV1Fields = {
  id: z.string().min(1),
  type: z.enum(["made", "found"]),
  title: z.string().min(1),
  memoryDate: isoDateTimeString,
  createdAt: isoDateTimeString,
  updatedAt: isoDateTimeString,
  photoRefs: z.array(photoRefV1Schema).min(1),
  note: z.string().min(1).optional(),
  schemaVersion: z.literal(1),
} as const;

export const madeFoodMemoryV1Schema = z
  .object({
    ...commonFoodMemoryV1Fields,
    type: z.literal("made"),
    dishName: z.string().min(1),
    ingredients: z.array(z.string().min(1)).min(1),
    comfortLevel: z.enum(["everyday", "cozy", "celebratory"]).optional(),
    madeContext: z.string().min(1).optional(),
  })
  .strict();

export const foundFoodMemoryV1Schema = z
  .object({
    ...commonFoodMemoryV1Fields,
    type: z.literal("found"),
    restaurantName: z.string().min(1),
    locationLabel: z.string().min(1),
    coordinate: z
      .object({
        latitude: z.number().min(-90).max(90),
        longitude: z.number().min(-180).max(180),
      })
      .strict()
      .optional(),
    discoverySource: z.enum(["walkBy", "friend", "search", "returnVisit"]).optional(),
    firstVisit: z.boolean().optional(),
    foundContext: z.string().min(1).optional(),
  })
  .strict();

export const foodMemoryV1Schema = z.discriminatedUnion("type", [
  madeFoodMemoryV1Schema,
  foundFoodMemoryV1Schema,
]);

export type FoodMemoryV1 = z.infer<typeof foodMemoryV1Schema>;
export type MadeFoodMemoryV1 = z.infer<typeof madeFoodMemoryV1Schema>;
export type FoundFoodMemoryV1 = z.infer<typeof foundFoodMemoryV1Schema>;

export const generatedFoodMemoryV1JsonSchema = z.toJSONSchema(foodMemoryV1Schema, {
  target: "draft-7",
});
