export type FoodLifeErrorCode =
  | 'validation_failed'
  | 'storage_unavailable'
  | 'quota_exceeded'
  | 'migration_unsupported'

export class FoodLifeError extends Error {
  readonly code: FoodLifeErrorCode
  readonly cause?: unknown

  constructor(code: FoodLifeErrorCode, message: string, cause?: unknown) {
    super(message)
    this.name = 'FoodLifeError'
    this.code = code
    this.cause = cause
  }
}

export const isFoodLifeError = (error: unknown): error is FoodLifeError =>
  error instanceof FoodLifeError
