import type { FoodMemory } from '../domain/food-memory'

export interface FoodMemoryRepository {
  createMemory(memory: FoodMemory): Promise<FoodMemory>
  updateMemory(id: string, memory: FoodMemory): Promise<FoodMemory>
  deleteMemory(id: string): Promise<boolean>
  getMemory(id: string): Promise<FoodMemory | null>
  listTimeline(): Promise<FoodMemory[]>
}
