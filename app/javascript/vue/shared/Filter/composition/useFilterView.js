// View-state management for filter task pages: the table sort (see
// useSortKeys), the user's saved default sort, the save action, and dirty
// tracking for the SaveViewButton. Freeze/hide/column order are
// TableResults' own, see its saveViewAsDefault.
//
// Set up by useFilter when given an `objectType`; filter task app.vue files
// drop the returned template ref onto FilterList/TableResults.

import { computed, ref, useTemplateRef, watch } from 'vue'
import { useUserPreference, useUserPreferences } from '@/composables'
import { serializeSortKeys } from '@/helpers/arrays.js'
import useSortKeys, {
  applicableSortKeys,
  sortKeysEqual
} from './useSortKeys.js'

export default function useFilterView({
  parameters,
  makeFilterRequest,
  objectType,
  sortableKeys = ref(null),
  maxSortKeys = ref(null)
}) {
  const sortKeysPref = useUserPreference(
    `tasks::filters::${objectType}::sortKeys`,
    []
  )
  const { loaded: preferencesLoaded, persistPreferences } =
    useUserPreferences()
  const filterListRef = useTemplateRef('filterListRef')
  const unsavedViewChanges = ref(false)

  // A saved pref can hold keys that are no longer sortable (renamed,
  // removed): compare and apply only the ones that still are.
  const savedSortKeys = computed(() =>
    applicableSortKeys(
      JSON.parse(JSON.stringify(sortKeysPref.value ?? [])),
      sortableKeys.value,
      maxSortKeys.value
    )
  )

  // Saved sort, applied during setup when preferences are already loaded
  // (sessionStorage cache): before useFilter's onBeforeMount sends the first
  // request, so that request is sorted too. A `sort` in the URL (or session
  // state), even an empty one, is merged in afterwards by useFilter and wins.
  // Set before useSortKeys reads it, so no pending sort change is left to
  // overwrite the URL's sort.
  if (preferencesLoaded.value && parameters.value.sort == null) {
    const saved = savedSortKeys.value
    if (saved.length) {
      parameters.value.sort = serializeSortKeys(saved)
    }
  }

  const { sortKeys, setSortKeysQuietly } = useSortKeys({
    parameters,
    makeFilterRequest,
    sortableKeys,
    maxSortKeys
  })

  // Cold start: preferences arrive later. Apply the saved sort once, when
  // they finish loading (not on later preference changes), unless a sort is
  // already set. If results are already showing (a request has set the URL
  // query), refetch so the list matches the sort shown.
  watch(preferencesLoaded, (loaded) => {
    if (!loaded || parameters.value.sort != null || sortKeys.value.length) {
      return
    }
    const saved = savedSortKeys.value
    if (!saved.length) return
    if (window.location.search) {
      sortKeys.value = saved
    } else {
      setSortKeysQuietly(saved)
    }
  })

  // Reset replaces `parameters`: back to the saved sort, as on a fresh load.
  watch(
    () => parameters.value,
    (next, previous) => {
      if (next === previous || next.sort != null) return
      setSortKeysQuietly(savedSortKeys.value)
    }
  )

  const hasUnsavedSortChanges = computed(
    () => !sortKeysEqual(sortKeys.value, savedSortKeys.value)
  )

  const hasUnsavedChanges = computed(
    () => hasUnsavedSortChanges.value || unsavedViewChanges.value
  )

  // Persist current session state (sort + freeze + hide + column order) as
  // the user's default. TableResults#saveViewAsDefault handles its own
  // state; here we handle sort. Deep-clone to strip Vue reactive proxies
  // before persist (BroadcastChannel.postMessage uses structuredClone).
  async function saveViewAsDefault() {
    filterListRef.value?.saveViewAsDefault()
    sortKeysPref.value = JSON.parse(JSON.stringify(sortKeys.value))

    const saved = await persistPreferences()

    TW.workbench.alert.create(
      saved
        ? 'View saved as your default.'
        : 'The view could not be saved, try again.',
      saved ? 'notice' : 'error'
    )
  }

  return {
    sortKeys,
    unsavedViewChanges,
    hasUnsavedChanges,
    filterListRef,
    saveViewAsDefault
  }
}
