import { computed } from 'vue'
import { useUserPreferences } from './useUserPreferences'

export function useUserPreference(key, defaultValue) {
  const { preferences, setPreference } = useUserPreferences()

  return computed({
    get: () => preferences.value?.layout?.[key] ?? defaultValue,
    set: (value) => setPreference(key, value)
  })
}
