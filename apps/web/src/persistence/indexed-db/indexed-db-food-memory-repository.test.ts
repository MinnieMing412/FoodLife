import 'fake-indexeddb/auto'

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import type { FoodMemory } from '../../domain/food-memory'
import { FoodLifeError } from '../../domain/food-life-error'
import { createIndexedDbFoodMemoryRepository } from './indexed-db-food-memory-repository'

import foundMemoryFixture from '../../../../../packages/schema-contract/fixtures/found-memory.valid.json'
import madeMemoryFixture from '../../../../../packages/schema-contract/fixtures/made-memory.valid.json'
import timelineOrder from '../../../../../packages/schema-contract/expected/timeline-order.json'

const madeMemory = madeMemoryFixture as FoodMemory
const foundMemory = foundMemoryFixture as FoodMemory

const deleteDatabase = (databaseName: string) =>
  new Promise<void>((resolve, reject) => {
    const request = indexedDB.deleteDatabase(databaseName)
    request.onerror = () => reject(request.error)
    request.onsuccess = () => resolve()
    request.onblocked = () => reject(new Error(`Database ${databaseName} deletion blocked`))
  })

describe('IndexedDbFoodMemoryRepository', () => {
  let databaseName: string

  beforeEach(() => {
    databaseName = `foodlife-test-${crypto.randomUUID()}`
  })

  afterEach(async () => {
    vi.restoreAllMocks()
    await deleteDatabase(databaseName)
  })

  it('creates, retrieves, updates, lists, and deletes made and found memories', async () => {
    const repository = createIndexedDbFoodMemoryRepository({ databaseName })

    await expect(repository.createMemory(madeMemory)).resolves.toEqual(madeMemory)
    await expect(repository.createMemory(foundMemory)).resolves.toEqual(foundMemory)

    await expect(repository.getMemory(madeMemory.id)).resolves.toEqual(madeMemory)
    await expect(repository.getMemory(foundMemory.id)).resolves.toEqual(foundMemory)

    const updatedMadeMemory: FoodMemory = {
      ...madeMemory,
      title: 'Miso soup with extra scallions',
      updatedAt: '2026-04-18T21:15:00-07:00',
    }

    await expect(
      repository.updateMemory(madeMemory.id, updatedMadeMemory),
    ).resolves.toEqual(updatedMadeMemory)
    await expect(repository.getMemory(madeMemory.id)).resolves.toEqual(updatedMadeMemory)

    await expect(repository.listTimeline()).resolves.toEqual([
      foundMemory,
      updatedMadeMemory,
    ])

    await expect(repository.deleteMemory(foundMemory.id)).resolves.toEqual(true)
    await expect(repository.getMemory(foundMemory.id)).resolves.toBeNull()
    await expect(repository.deleteMemory(foundMemory.id)).resolves.toEqual(false)
  })

  it('sorts timeline results by memoryDate descending using canonical expectations', async () => {
    const repository = createIndexedDbFoodMemoryRepository({ databaseName })

    await repository.createMemory(madeMemory)
    await repository.createMemory(foundMemory)

    const timeline = await repository.listTimeline()

    expect(timeline.map((memory) => memory.id)).toEqual(timelineOrder.memoryIds)
  })

  it('sorts timeline results by instant rather than lexicographic ISO text', async () => {
    const repository = createIndexedDbFoodMemoryRepository({ databaseName })
    const earlierWallClockMemory: FoodMemory = {
      ...madeMemory,
      id: 'made-2026-05-02-late-wall-clock',
      title: 'Late wall clock snack',
      memoryDate: '2026-05-02T23:30:00+09:00',
      createdAt: '2026-05-02T23:45:00+09:00',
      updatedAt: '2026-05-02T23:45:00+09:00',
      photoRefs: [
        {
          ...madeMemory.photoRefs[0],
          id: 'photo-made-late-wall-clock-1',
          createdAt: '2026-05-02T23:44:00+09:00',
        },
      ],
    }
    const laterInstantMemory: FoodMemory = {
      ...foundMemory,
      id: 'found-2026-05-02-later-instant',
      title: 'Later instant tart',
      memoryDate: '2026-05-02T08:00:00-07:00',
      createdAt: '2026-05-02T08:15:00-07:00',
      updatedAt: '2026-05-02T08:15:00-07:00',
      photoRefs: [
        {
          ...foundMemory.photoRefs[0],
          id: 'photo-found-later-instant-1',
          createdAt: '2026-05-02T08:14:00-07:00',
        },
      ],
    }

    await repository.createMemory(earlierWallClockMemory)
    await repository.createMemory(laterInstantMemory)

    const timeline = await repository.listTimeline()

    expect(timeline.map((memory) => memory.id)).toEqual([
      laterInstantMemory.id,
      earlierWallClockMemory.id,
    ])
  })

  it('retrieves persisted records after constructing a new repository instance', async () => {
    const firstRepository = createIndexedDbFoodMemoryRepository({ databaseName })
    await firstRepository.createMemory(madeMemory)

    const restartedRepository = createIndexedDbFoodMemoryRepository({ databaseName })

    await expect(restartedRepository.getMemory(madeMemory.id)).resolves.toEqual(madeMemory)
  })

  it('rejects invalid records with stable validation failures', async () => {
    const repository = createIndexedDbFoodMemoryRepository({ databaseName })
    const invalidMemory = {
      ...madeMemory,
      dishName: undefined,
    } as unknown as FoodMemory

    await expect(repository.createMemory(invalidMemory)).rejects.toMatchObject({
      code: 'validation_failed',
    } satisfies Partial<FoodLifeError>)
  })

  it('does not call network APIs during persistence operations', async () => {
    const fetchSpy = vi
      .spyOn(globalThis, 'fetch')
      .mockRejectedValue(new Error('network disabled'))
    const xhrOpenSpy = vi.spyOn(XMLHttpRequest.prototype, 'open')
    const repository = createIndexedDbFoodMemoryRepository({ databaseName })

    await repository.createMemory(madeMemory)
    await repository.getMemory(madeMemory.id)
    await repository.updateMemory(madeMemory.id, {
      ...madeMemory,
      title: 'Miso soup with quiet leftovers',
      updatedAt: '2026-04-18T22:00:00-07:00',
    })
    await repository.listTimeline()
    await repository.deleteMemory(madeMemory.id)

    expect(fetchSpy).not.toHaveBeenCalled()
    expect(xhrOpenSpy).not.toHaveBeenCalled()
  })
})
