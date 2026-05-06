/**
 * usePreferences.js
 *
 * Manages autoselect preferences persisted in localStorage.
 *
 * Preference structure (stored under STORAGE_KEY):
 * {
 *   "<project_id>": {              // numeric project id, or "global" when outside a project
 *     "<resource>": {              // e.g. "taxon_names", derived from the autoselect URL
 *       "<autoselect-id>": {
 *         "levels": {
 *           "<level_key>": {
 *             "hide": Boolean,     // when true this level is hidden from the fuse bar
 *             "options": {}        // arbitrary key/value pairs passed to the server on search
 *           }
 *         },
 *         "show_info":  Boolean,   // when false, info column is hidden; default true
 *         "auto_jump":  Boolean    // when false, fuse does not auto-escalate; default true
 *       }
 *     }
 *   }
 * }
 */

import { getCurrentProjectId } from '@/helpers/project.js'

const STORAGE_KEY = 'tw_autoselect_prefs'

function loadAll() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}')
  } catch {
    return {}
  }
}

function saveAll(all) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(all))
}

function projectKey() {
  return String(getCurrentProjectId() || 'global')
}

/**
 * @param {string} url   - The autoselect endpoint URL, e.g. '/taxon_names/autoselect'
 * @param {string} id    - The unique id of this autoselect instance
 */
export function usePreferences(url, id) {
  // Derive the resource segment from the URL: '/taxon_names/autoselect' → 'taxon_names'
  const resource = url.replace(/^\//, '').split('/')[0]

  function getPrefs() {
    const all = loadAll()
    return all[projectKey()]?.[resource]?.[id] || { levels: {} }
  }

  function savePrefs(prefs) {
    const all = loadAll()
    const pk = projectKey()
    all[pk] ??= {}
    all[pk][resource] ??= {}
    all[pk][resource][id] = prefs
    saveAll(all)
  }

  /** @param {string} levelKey */
  function isLevelVisible(levelKey) {
    return !(getPrefs().levels?.[levelKey]?.hide === true)
  }

  /**
   * Returns the options hash for a given level (e.g. { dataset_id: '3LR' }).
   * @param {string} levelKey
   * @returns {Object}
   */
  function getLevelOptions(levelKey) {
    return getPrefs().levels?.[levelKey]?.options || {}
  }

  /** Whether info column is shown (defaults to true when not set). */
  function getShowInfo() {
    return getPrefs().show_info !== false
  }

  /** Toggle info display and persist. */
  function toggleShowInfo() {
    const current = getPrefs()
    savePrefs({ ...current, show_info: !getShowInfo() })
  }

  /** Whether the fuse auto-escalates to the next level on empty results (defaults to true). */
  function getAutoJump() {
    return getPrefs().auto_jump !== false
  }

  return { getPrefs, savePrefs, isLevelVisible, getLevelOptions, getShowInfo, toggleShowInfo, getAutoJump }
}
