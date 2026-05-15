import { FoodLifeError } from '../../domain/food-life-error'
import type { FoodMemory } from '../../domain/food-memory'

export const FOOD_LIFE_DB_VERSION = 1
export const MEMORIES_STORE_NAME = 'memories'

export type PersistedFoodMemoryRecord = FoodMemory

export interface FoodLifeDbOptions {
  databaseName?: string
}

export const DEFAULT_FOOD_LIFE_DB_NAME = 'foodlife-local'

export const openFoodLifeDb = ({
  databaseName = DEFAULT_FOOD_LIFE_DB_NAME,
}: FoodLifeDbOptions = {}): Promise<IDBDatabase> => {
  if (!globalThis.indexedDB) {
    return Promise.reject(
      new FoodLifeError(
        'storage_unavailable',
        'IndexedDB storage is not available in this environment.',
      ),
    )
  }

  return new Promise((resolve, reject) => {
    const request = indexedDB.open(databaseName, FOOD_LIFE_DB_VERSION)

    request.onupgradeneeded = () => {
      const database = request.result

      if (!database.objectStoreNames.contains(MEMORIES_STORE_NAME)) {
        const memoriesStore = database.createObjectStore(MEMORIES_STORE_NAME, {
          keyPath: 'id',
        })
        memoriesStore.createIndex('type', 'type', { unique: false })
        memoriesStore.createIndex('memoryDate', 'memoryDate', { unique: false })
        memoriesStore.createIndex('updatedAt', 'updatedAt', { unique: false })
      }
    }

    request.onerror = () => reject(mapIndexedDbError(request.error))
    request.onblocked = () =>
      reject(
        new FoodLifeError(
          'migration_unsupported',
          'FoodLife local storage migration was blocked by another open connection.',
          request.error,
        ),
      )
    request.onsuccess = () => resolve(request.result)
  })
}

export const mapIndexedDbError = (error: unknown): FoodLifeError => {
  if (error instanceof FoodLifeError) {
    return error
  }

  if (error instanceof DOMException) {
    if (error.name === 'QuotaExceededError') {
      return new FoodLifeError(
        'quota_exceeded',
        'FoodLife local storage quota has been exceeded.',
        error,
      )
    }

    if (error.name === 'VersionError') {
      return new FoodLifeError(
        'migration_unsupported',
        'This FoodLife local storage version is not supported.',
        error,
      )
    }
  }

  return new FoodLifeError(
    'storage_unavailable',
    'FoodLife local storage operation failed.',
    error,
  )
}
