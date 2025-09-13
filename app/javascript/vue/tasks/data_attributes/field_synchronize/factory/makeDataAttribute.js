import { randomUUID } from '@/helpers'

export function makeDataAttribute({ predicateId, value = '', id = null }) {
  return {
    id,
    uuid: randomUUID(),
    predicateId,
    value
  }
}
