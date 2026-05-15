import {
  foodMemoryV1Schema,
  type FoodMemoryV1,
  type FoundFoodMemoryV1,
  type MadeFoodMemoryV1,
} from '@foodlife/schema-contract'
import { FoodLifeError } from './food-life-error'

export type FoodMemory = FoodMemoryV1
export type MadeFoodMemory = MadeFoodMemoryV1
export type FoundFoodMemory = FoundFoodMemoryV1
export type FoodMemoryType = FoodMemory['type']

export const parseFoodMemory = (value: unknown): FoodMemory => {
  const result = foodMemoryV1Schema.safeParse(value)

  if (!result.success) {
    throw new FoodLifeError(
      'validation_failed',
      'Food memory does not match the FoodMemory v1 contract.',
      result.error,
    )
  }

  return result.data
}
