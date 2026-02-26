/**
 * useAutoselect.js
 *
 * Composable for fetching and caching Autoselect config from a given endpoint URL.
 * Deduplicates config fetches across component instances using a module-level Map.
 */

import { ref } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'

// Module-level cache: url -> config hash (avoids re-fetching on re-mount)
const configCache = new Map()

export function useAutoselect(url) {
  const config = ref(null)

  async function fetchConfig() {
    if (configCache.has(url)) {
      config.value = configCache.get(url)
      return config.value
    }

    try {
      const { body } = await AjaxCall('get', url)
      if (body && body.config) {
        configCache.set(url, body)
        config.value = body
      }
    } catch (e) {
      console.warn('[useAutoselect] Failed to fetch config from', url, e)
    }

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
