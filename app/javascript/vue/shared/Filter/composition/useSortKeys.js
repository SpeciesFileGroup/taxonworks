// Keeps a filter's table sort (`sortKeys`, as shown by TableResults and
// SortPanel) and its `sort` request parameter in step:
//
// - a sort change from the user sets `parameters.sort` and requests page 1
//   again, sorted
// - a `sort` from the URL (or browser navigation) sets `sortKeys`
// - keys that aren't sortable, repeats, and keys past the backend's limit are
//   dropped, as the backend drops them, so the sort shown is the sort applied
//
// An explicitly cleared sort is kept as `sort: ''`, so a reload or shared
// link shows it cleared rather than falling back to a saved default.

import { ref, watch } from 'vue'
import { serializeSortKeys, parseSortParam } from '@/helpers/arrays.js'

// '' for no keys: a cleared sort, as sent and kept in the URL.
const serialize = (keys) => serializeSortKeys(keys) ?? ''

// @return [Array] keys without repeats, unsortable keys (when sortableKeys
//   is known) and keys past maxSortKeys (when known), as the backend drops
//   them
export function applicableSortKeys(keys, sortableKeys = null, maxSortKeys = null) {
  const seen = new Set()
  let result = (keys ?? []).filter(({ key }) => {
    if (seen.has(key)) return false
    seen.add(key)
    return true
  })
  if (Array.isArray(sortableKeys)) {
    result = result.filter(({ key }) => sortableKeys.includes(key))
  }
  if (maxSortKeys != null) {
    result = result.slice(0, maxSortKeys)
  }
  return result
}

export function sortKeysEqual(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b)) return false
  if (a.length !== b.length) return false
  for (let i = 0; i < a.length; i++) {
    if (a[i]?.key !== b[i]?.key || a[i]?.dir !== b[i]?.dir) return false
  }
  return true
}

// @param parameters [Ref<Object>] the filter's parameters
// @param makeFilterRequest [Function] see useFilter
// @param sortableKeys [Ref<Array|null>] null until known (no gating)
// @param maxSortKeys [Ref<Number|null>] null until known (no limit)
// @param canFetch [Function] whether a sort change should request results;
//   by default only once a search has run (the URL has a query)
// @param requestParameters [Function] extra parameters for that request
export default function useSortKeys({
  parameters,
  makeFilterRequest,
  sortableKeys = ref(null),
  maxSortKeys = ref(null),
  canFetch = () => !!window.location.search,
  requestParameters = () => ({})
}) {
  // Set by setSortKeysQuietly: the next sortKeys change updates
  // `parameters.sort` without a request, e.g. when hydrating from the URL or
  // a saved default (users usually set facets before searching).
  let suppressNextFetch = false

  const applicable = (keys) =>
    applicableSortKeys(keys, sortableKeys.value, maxSortKeys.value)

  // From `parameters.sort` as it is now: set any default before this.
  const sortKeys = ref(applicable(parseSortParam(parameters.value.sort)))

  // Sets the sort without a request. A no-op (and no suppression left
  // behind for the next real change) when keys are already the sort.
  function setSortKeysQuietly(keys) {
    if (sortKeysEqual(keys, sortKeys.value)) return
    suppressNextFetch = true
    sortKeys.value = keys
  }

  watch(
    sortKeys,
    (next) => {
      const sortString = serialize(next)
      if (sortString === (parameters.value.sort ?? '')) {
        suppressNextFetch = false
        return
      }
      parameters.value.sort = sortString
      if (suppressNextFetch || !canFetch()) {
        suppressNextFetch = false
        return
      }
      // A new sort starts a new list, also in append mode.
      makeFilterRequest(
        { ...parameters.value, ...requestParameters(), page: 1 },
        { append: false }
      )
    },
    { deep: true }
  )

  watch(
    () => parameters.value.sort,
    (next) => {
      if ((next ?? '') === serialize(sortKeys.value)) return
      // The request that set this sort has run (or is running) already.
      setSortKeysQuietly(applicable(parseSortParam(next)))
    }
  )

  // Sortable keys and the limit arrive after hydration: drop keys that
  // turn out not to apply. No request, the backend already ignored them.
  watch([sortableKeys, maxSortKeys], () => {
    setSortKeysQuietly(applicable(sortKeys.value))
  })

  return {
    sortKeys,
    setSortKeysQuietly
  }
}
