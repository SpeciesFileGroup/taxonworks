import { STORAGE_FILTER_QUERY_KEY } from '@/constants'

export function getParametersFromSession(sessionId) {
  const filterQuery = JSON.parse(localStorage.getItem(STORAGE_FILTER_QUERY_KEY))
  const parameters = filterQuery?.[sessionId]

  return parameters || {}
}
