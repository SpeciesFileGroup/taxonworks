import { ref, computed, toRaw } from 'vue'
import { User } from '@/routes/endpoints'

const preferences = ref({})
const isLoading = ref(false)
const error = ref(null)
const loaded = ref(false)

const STORAGE_KEY = 'tw_user_preferences'
const CHANNEL_NAME = 'tw_user_preferences'

let channel = null

function getChannel() {
  if (!channel && typeof window !== 'undefined' && window.BroadcastChannel) {
    channel = new BroadcastChannel(CHANNEL_NAME)
    channel.addEventListener('message', ({ data }) => {
      preferences.value = data

      if (data) {
        sessionStorage.setItem(STORAGE_KEY, JSON.stringify(data))
      } else {
        sessionStorage.removeItem(STORAGE_KEY)
      }
    })
  }

  return channel
}

function post(data) {
  getChannel()?.postMessage(toRaw(data))
}

const loadPreferences = async (forceReload = false) => {
  if (loaded.value && !forceReload) return preferences.value

  const saved = sessionStorage.getItem(STORAGE_KEY)

  if (!forceReload && saved) {
    preferences.value = JSON.parse(saved)
    loaded.value = true

    return preferences.value
  }

  isLoading.value = true
  error.value = null

  try {
    const { body } = await User.preferences()

    preferences.value = body
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify(body))
    loaded.value = true

    return body
  } catch (err) {
    error.value = err
    console.error('Error loading preferences:', err)

    throw err
  } finally {
    isLoading.value = false
  }
}

const syncStorage = () => {
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify(preferences.value))

  post(preferences.value)
}

const PERSIST_DEBOUNCE_MS = 300
let pendingLayoutUpdates = {}
let persistTimer = null

async function flushPersist() {
  persistTimer = null

  const userId = preferences.value?.id
  const batch = pendingLayoutUpdates

  if (!userId || !Object.keys(batch).length) return

  pendingLayoutUpdates = {}

  try {
    await User.update(userId, { user: { layout: batch } })
  } catch (err) {
    console.error('Failed to persist user preferences:', err)
  }
}

function schedulePersist(key, value) {
  pendingLayoutUpdates[key] = value

  if (persistTimer) clearTimeout(persistTimer)
  persistTimer = setTimeout(flushPersist, PERSIST_DEBOUNCE_MS)
}

if (typeof window !== 'undefined') {
  window.addEventListener('beforeunload', () => {
    if (persistTimer) {
      clearTimeout(persistTimer)
      flushPersist()
    }
  })
}

const setPreference = async (key, value, opts = { persist: true }) => {
  await loadPreferences()

  if (preferences.value?.layout?.[key] === value) return

  if (!preferences.value) {
    preferences.value = {
      layout: {
        [key]: value
      }
    }
  } else if (!preferences.value?.layout) {
    preferences.value.layout = {
      [key]: value
    }
  } else {
    preferences.value.layout[key] = value
  }

  syncStorage()

  if (opts.persist && preferences.value.id) {
    schedulePersist(key, value)
  }
}

const clearPreferences = () => {
  preferences.value = null
  sessionStorage.removeItem(STORAGE_KEY)
  loaded.value = false
  post(preferences.value)
}

export function useUserPreferences() {
  getChannel()

  if (!isLoading.value && !loaded.value) {
    loadPreferences()
  }

  return {
    preferences: computed(() => preferences.value),
    isLoading: computed(() => isLoading.value),
    error: computed(() => error.value),
    loaded: computed(() => loaded.value),
    loadPreferences,
    setPreference,
    clearPreferences
  }
}
