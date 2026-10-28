import { IDENTIFIER_SEPARATOR } from '@/shared/Filter/constants'

export function listParser(list) {
  return list.map((item) => ({
    ...item,
    identifiers: item.identifiers?.join(IDENTIFIER_SEPARATOR)
  }))
}
