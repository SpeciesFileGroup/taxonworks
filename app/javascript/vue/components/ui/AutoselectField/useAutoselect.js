/**
 * useAutoselect.js
 *
 * Composable for fetching and caching Autoselect config from a given endpoint URL.
 * Deduplicates config fetches across component instances using a module-level Map.
 */

import { ref } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'

const configRequests = new Map()

// Extra params (e.g. col_valid_names) change which levels the server returns, so
// they must be part of the cache key — otherwise two instances of the same url with
// different extraParams would clobber each other's cached level map.
function cacheKey(url, extraParams) {
  const entries = Object.entries(extraParams).sort(([a], [b]) => a.localeCompare(b))
  return entries.length ? `${url}?${new URLSearchParams(entries).toString()}` : url
}

function requestConfig(url, extraParams) {
  const key = cacheKey(url, extraParams)

  if (!configRequests.has(key)) {
    const request = AjaxCall('get', url, { params: extraParams })
      .then(({ body }) => {
        if (body && body.config) return body

        configRequests.delete(key)
        return null
      })
      .catch((e) => {
        console.warn('[useAutoselect] Failed to fetch config from', url, e)
        configRequests.delete(key)
        return null
      })

    configRequests.set(key, request)
  }

  return configRequests.get(key)
}

/**
 * @param {string} url
 * @param {Object} [extraParams] - extra query params sent with every request (config
 *   and term search alike) — e.g. { col_valid_names: true } to opt a specific
 *   autoselect instance into a task-specific level. Read once at call time; pass a
 *   plain object, not a ref (component owns reactivity, this composable doesn't).
 */
export function useAutoselect(url, extraParams = {}) {
  const config = ref(null)

  async function fetchConfig() {
    const body = await requestConfig(url, extraParams)
    if (body) config.value = body

    return config.value
  }

  function getFirstLevelKey() {
    if (!config.value?.map?.length) return null
    return config.value.map[0]
  }

  function getNextLevelKey(currentKey) {
    const map = config.value?.map
    if (!map) return null
    const idx = map.indexOf(currentKey)
    if (idx < 0 || idx >= map.length - 1) return null
    return map[idx + 1]
  }

  function isExternalLevel(key) {
    if (!config.value?.levels) return false
    const level = config.value.levels.find((l) => String(l.key) === String(key))
    return level?.external ?? false
  }

  function getFuseMs(key) {
    if (!config.value?.levels) return 600
    const level = config.value.levels.find((l) => String(l.key) === String(key))
    return level?.fuse_ms ?? 600
  }

  function getOperators() {
    return config.value?.operators ?? []
  }

  return {
    config,
    fetchConfig,
    getFirstLevelKey,
    getNextLevelKey,
    isExternalLevel,
    getFuseMs,
    getOperators
  }
}
