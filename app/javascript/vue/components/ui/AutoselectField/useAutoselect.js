/**
 * useAutoselect.js
 *
 * Composable for fetching and caching Autoselect config from a given endpoint URL.
 * Deduplicates config fetches across component instances using a module-level Map.
 */

import { ref } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'

const configRequests = new Map()

function requestConfig(url) {
  if (!configRequests.has(url)) {
    const request = AjaxCall('get', url)
      .then(({ body }) => {
        if (body && body.config) return body

        configRequests.delete(url)
        return null
      })
      .catch((e) => {
        console.warn('[useAutoselect] Failed to fetch config from', url, e)
        configRequests.delete(url)
        return null
      })

    configRequests.set(url, request)
  }

  return configRequests.get(url)
}

export function useAutoselect(url) {
  const config = ref(null)

  async function fetchConfig() {
    const body = await requestConfig(url)
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
