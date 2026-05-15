import { FoodLifeError, isFoodLifeError } from '../../domain/food-life-error'
import { parseFoodMemory, type FoodMemory } from '../../domain/food-memory'
import type { FoodMemoryRepository } from '../../services/food-memory-repository'
import {
  MEMORIES_STORE_NAME,
  mapIndexedDbError,
  openFoodLifeDb,
  type FoodLifeDbOptions,
  type PersistedFoodMemoryRecord,
} from './food-life-db'

type TransactionMode = IDBTransactionMode

export type IndexedDbFoodMemoryRepositoryOptions = FoodLifeDbOptions

export const createIndexedDbFoodMemoryRepository = (
  options: IndexedDbFoodMemoryRepositoryOptions = {},
): FoodMemoryRepository => new IndexedDbFoodMemoryRepository(options)

class IndexedDbFoodMemoryRepository implements FoodMemoryRepository {
  private readonly options: IndexedDbFoodMemoryRepositoryOptions

  constructor(options: IndexedDbFoodMemoryRepositoryOptions) {
    this.options = options
  }

  async createMemory(memory: FoodMemory): Promise<FoodMemory> {
    const validatedMemory = parseFoodMemory(memory)
    await this.withMemoriesStore('readwrite', (store) =>
      requestToPromise(store.add(validatedMemory)),
    )
    return validatedMemory
  }

  async updateMemory(id: string, memory: FoodMemory): Promise<FoodMemory> {
    const validatedMemory = parseFoodMemory(memory)

    if (validatedMemory.id !== id) {
      throw new FoodLifeError(
        'validation_failed',
        'Food memory id must match the requested update id.',
      )
    }

    const existingMemory = await this.getMemory(id)

    if (!existingMemory) {
      throw new FoodLifeError(
        'validation_failed',
        'Cannot update a food memory that does not exist.',
      )
    }

    await this.withMemoriesStore('readwrite', (store) =>
      requestToPromise(store.put(validatedMemory)),
    )
    return validatedMemory
  }

  async deleteMemory(id: string): Promise<boolean> {
    const existingMemory = await this.getMemory(id)

    if (!existingMemory) {
      return false
    }

    await this.withMemoriesStore('readwrite', (store) =>
      requestToPromise(store.delete(id)),
    )
    return true
  }

  async getMemory(id: string): Promise<FoodMemory | null> {
    const record = await this.withMemoriesStore('readonly', (store) =>
      requestToPromise<PersistedFoodMemoryRecord | undefined>(store.get(id)),
    )

    return record ? parseFoodMemory(record) : null
  }

  async listTimeline(): Promise<FoodMemory[]> {
    const records = await this.withMemoriesStore('readonly', (store) =>
      requestToPromise<PersistedFoodMemoryRecord[]>(store.getAll()),
    )

    return records
      .map((record) => parseFoodMemory(record))
      .sort(
        (left, right) =>
          Date.parse(right.memoryDate) - Date.parse(left.memoryDate),
      )
  }

  private async withMemoriesStore<T>(
    mode: TransactionMode,
    operation: (store: IDBObjectStore) => Promise<T>,
  ): Promise<T> {
    let database: IDBDatabase | undefined

    try {
      database = await openFoodLifeDb(this.options)
      const transaction = database.transaction(MEMORIES_STORE_NAME, mode)
      const store = transaction.objectStore(MEMORIES_STORE_NAME)
      const result = await operation(store)
      await transactionComplete(transaction)
      return result
    } catch (error) {
      throw isFoodLifeError(error) ? error : mapIndexedDbError(error)
    } finally {
      database?.close()
    }
  }
}

const requestToPromise = <T>(request: IDBRequest<T>): Promise<T> =>
  new Promise((resolve, reject) => {
    request.onerror = () => reject(request.error)
    request.onsuccess = () => resolve(request.result)
  })

const transactionComplete = (transaction: IDBTransaction): Promise<void> =>
  new Promise((resolve, reject) => {
    transaction.oncomplete = () => resolve()
    transaction.onerror = () => reject(transaction.error)
    transaction.onabort = () => reject(transaction.error)
  })
