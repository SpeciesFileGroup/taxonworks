import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { User } from '@/routes/endpoints'
import { useBroadcastChannel } from './useBroadcastChannel'

const preferences = ref(null)
const isLoading = ref(false)
const error = ref(null)
const loaded = ref(false)

const STORAGE_KEY = 'tw_user_preferences'

export function useUserPreferences() {
  const { post } = useBroadcastChannel({
    name: 'tw_user_preferences',
    onMessage({ data }) {
      preferences.value = data
    }
  })

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

  const setPreference = async (key, value, opts = { persist: true }) => {
    if (!preferences.value) {
      preferences.value = {
        layout: {}
      }
    }

    if (!preferences.value.layout) {
      preferences.value.layout = {}
    }

    preferences.value.layout[key] = value

    syncStorage()

    if (opts.persist) {
      try {
        await User.update(preferences.value.id, {
          user: {
            layout: {
              [key]: value
            }
          }
        })
      } catch (err) {
        console.error('Failed to persist user preference:', err)
      }
    }
  }

  const clearPreferences = () => {
    preferences.value = null
    sessionStorage.removeItem(STORAGE_KEY)
    loaded.value = false
    post(preferences.value)
  }

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
