// View-state management for filter task pages: sort state, sort URL
// round-trip, sort/freeze/hide persistence via useUserPreference, save
// action, and dirty tracking for the SaveViewButton.
//
// Filter task app.vue files call this alongside useFilter and drop the
// returned template ref onto FilterList/TableResults.

import { computed, ref, useTemplateRef, watch } from 'vue'
import { useUserPreference, useUserPreferences } from '@/composables'
import { serializeSortKeys, parseSortParam } from '@/helpers/arrays.js'
import { maxSortKeys } from '@/shared/Filter/utils'

function sortKeysEqual(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b)) return false
  if (a.length !== b.length) return false
  for (let i = 0; i < a.length; i++) {
    if (a[i]?.key !== b[i]?.key || a[i]?.dir !== b[i]?.dir) return false
  }
  return true
}

export default function useFilterView({
  parameters,
  makeFilterRequest,
  objectType,
  extend = [],
  exclude = undefined,
  sortableKeys = ref(null)
}) {
  const sortKeysPref = useUserPreference(
    `tasks::filters::${objectType}::sortKeys`,
    []
  )
  const { loaded: preferencesLoaded } = useUserPreferences()
  const filterListRef = useTemplateRef('filterListRef')
  const unsavedViewChanges = ref(false)
  const sortKeys = ref(parseSortParam(parameters.value.sort))

  // When hydration (from pref or URL) sets sortKeys programmatically we
  // want the display + `parameters.sort` to reflect it, but we don't want
  // to fire an automatic fetch -- users usually want to configure filter
  // facets before requesting data, so an eager refetch wastes a round-trip.
  // Set this flag right before a programmatic sortKeys assignment; the
  // sortKeys watcher will still update `parameters.sort` but skip the
  // makeFilterRequest call.
  let suppressNextFetch = false

  // Keys the backend sorts by, at most maxSortKeys of them. A saved pref or
  // URL can hold keys that are no longer sortable (renamed, removed); the
  // backend ignores those, so showing them would show a sort that isn't
  // applied. Until sortableKeys loads, keys are kept as given.
  function applicableSortKeys(keys) {
    let result = keys
    if (Array.isArray(sortableKeys.value)) {
      result = result.filter(({ key }) => sortableKeys.value.includes(key))
    }
    if (maxSortKeys.value != null) {
      result = result.slice(0, maxSortKeys.value)
    }
    return result
  }

  function savedSortKeys() {
    return applicableSortKeys(JSON.parse(JSON.stringify(sortKeysPref.value ?? [])))
  }

  // Saved sort, applied during setup when preferences are already loaded
  // (sessionStorage cache): before useFilter's onBeforeMount sends the first
  // request, so that request is sorted too. A `sort` in the URL (or session
  // state) is merged in afterwards by useFilter and wins.
  if (preferencesLoaded.value && !parameters.value.sort) {
    const saved = savedSortKeys()
    if (saved.length) {
      sortKeys.value = saved
      parameters.value.sort = serializeSortKeys(saved)
    }
  }

  // Cold start: preferences arrive later. Apply the saved sort once, when
  // they finish loading (not on later preference changes), unless a sort is
  // already set. If results are already showing (a request has set the URL
  // query), refetch so the list matches the sort shown.
  watch(preferencesLoaded, (loaded) => {
    if (!loaded || parameters.value.sort || sortKeys.value?.length) return
    const saved = savedSortKeys()
    if (!saved.length) return
    suppressNextFetch = !window.location.search
    sortKeys.value = saved
  })

  // sort keys change (user click, panel edit) -> URL param + refetch
  watch(
    sortKeys,
    (next) => {
      const sortString = serializeSortKeys(next)
      if (sortString === parameters.value.sort) {
        suppressNextFetch = false
        return
      }
      parameters.value.sort = sortString
      // No search yet (nothing in the URL query): just record the sort for
      // the first search, rather than fetching an unfiltered list.
      if (suppressNextFetch || !window.location.search) {
        suppressNextFetch = false
        return
      }
      const payload = { ...parameters.value, extend, page: 1 }
      if (exclude !== undefined) payload.exclude = exclude
      makeFilterRequest(payload)
    },
    { deep: true }
  )

  // URL sort param changes (browser nav, external) -> sort keys
  watch(
    () => parameters.value.sort,
    (next) => {
      if (next === serializeSortKeys(sortKeys.value)) return
      // The request that set this sort has run (or is running) already.
      suppressNextFetch = true
      sortKeys.value = applicableSortKeys(parseSortParam(next))
    }
  )

  // Reset replaces `parameters`: back to the saved sort, as on a fresh load.
  watch(
    () => parameters.value,
    (next, previous) => {
      if (next === previous || next.sort) return
      const saved = savedSortKeys()
      if (sortKeysEqual(saved, sortKeys.value)) return
      suppressNextFetch = true
      sortKeys.value = saved
    }
  )

  // Sortable keys arrive after hydration: drop keys that turn out not to be
  // sortable. No refetch, the backend already ignored them.
  watch(
    [sortableKeys, maxSortKeys],
    () => {
      const applicable = applicableSortKeys(sortKeys.value)
      if (sortKeysEqual(applicable, sortKeys.value)) return
      suppressNextFetch = true
      sortKeys.value = applicable
    }
  )

  const hasUnsavedSortChanges = computed(() =>
    !sortKeysEqual(sortKeys.value, sortKeysPref.value ?? [])
  )

  const hasUnsavedChanges = computed(
    () => hasUnsavedSortChanges.value || unsavedViewChanges.value
  )

  // Persist current session state (sort + freeze + hide) as the user's
  // default. TableResults#saveViewAsDefault handles freeze/hide; here we
  // handle sort. Deep-clone to strip Vue reactive proxies before persist
  // (BroadcastChannel.postMessage uses structuredClone).
  function saveViewAsDefault() {
    filterListRef.value?.saveViewAsDefault()
    sortKeysPref.value = JSON.parse(JSON.stringify(sortKeys.value))
  }

  return {
    sortKeys,
    unsavedViewChanges,
    hasUnsavedChanges,
    filterListRef,
    saveViewAsDefault
  }
}
