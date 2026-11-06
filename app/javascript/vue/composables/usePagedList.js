import { computed, ref, unref, watch } from 'vue'

export const FILTER_ALL = 'all'

// Client-side filtering and paging of a list, e.g. batch load results.
//
// @param items - a ref (or computed) of the full list
// @param keyOf - item => the value `filter` selects on (e.g. its status)
// @param matches - (item, filter) => Boolean, for filters that aren't a
//   keyOf value; defaults to keyOf(item) === filter
// @param perPage
// @param frozen - when true, which items the filter shows is captured when
//   the filter, the list, or a `refreshOn` source changes (or on refresh()),
//   not recomputed live, so that editing an item doesn't make it disappear
//   from under the user
// @param refreshOn - extra watch sources that re-capture a frozen filter
// @return {
//   filter, // ref: FILTER_ALL or a filter value
//   page, // ref: 1-based
//   visibleItems, pageItems, // computed
//   pagination, // computed, the object components/pagination.vue expects
//   setPage, // pagination.vue's nextPage handler
//   refresh // re-captures a frozen filter and returns to page 1
// }
export function usePagedList(
  items,
  {
    keyOf,
    matches = (item, filter) => keyOf(item) === filter,
    perPage = 100,
    frozen = false,
    refreshOn = []
  }
) {
  const filter = ref(FILTER_ALL)
  const page = ref(1)

  // frozen: the items the filter showed when last captured, null for all
  const capturedItems = ref(null)

  function liveVisibleItems() {
    const list = unref(items)
    return filter.value === FILTER_ALL
      ? list
      : list.filter((item) => matches(item, filter.value))
  }

  const visibleItems = computed(() => {
    if (!frozen) return liveVisibleItems()

    const list = unref(items)
    return capturedItems.value === null
      ? list
      : list.filter((item) => capturedItems.value.has(item))
  })

  const totalPages = computed(() =>
    Math.max(1, Math.ceil(visibleItems.value.length / perPage))
  )

  const pageItems = computed(() =>
    visibleItems.value.slice((page.value - 1) * perPage, page.value * perPage)
  )

  // As helpers/getPagination.js builds it from server headers.
  const pagination = computed(() => ({
    paginationPage: page.value,
    nextPage: Math.min(page.value + 1, totalPages.value),
    previousPage: Math.max(page.value - 1, 1),
    perPage,
    total: visibleItems.value.length,
    totalPages: totalPages.value
  }))

  function setPage({ page: newPage }) {
    page.value = newPage
  }

  function refresh() {
    page.value = 1

    if (frozen) {
      capturedItems.value =
        filter.value === FILTER_ALL ? null : new Set(liveVisibleItems())
    }
  }

  watch([filter, () => unref(items), ...refreshOn], refresh)

  return { filter, page, visibleItems, pageItems, pagination, setPage, refresh }
}
