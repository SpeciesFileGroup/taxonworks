// View-state management for filter task pages: sort state, sort URL
// round-trip, sort/freeze/hide persistence via useUserPreference, save
// action, and dirty tracking for the SaveViewButton.
//
// Filter task app.vue files call this alongside useFilter and drop the
// returned template ref onto FilterList/TableResults.

import { computed, onMounted, ref, useTemplateRef, watch } from 'vue'
import { useUserPreference } from '@/composables'
import { serializeSortKeys, parseSortParam } from '@/helpers/arrays.js'

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
  exclude = undefined
}) {
  const sortKeysPref = useUserPreference(
    `tasks::filters::${objectType}::sortKeys`,
    []
  )
  const filterListRef = useTemplateRef('filterListRef')
  const unsavedViewChanges = ref(false)
  const sortKeys = ref(parseSortParam(parameters.value.sort))

  onMounted(() => {
    if (!parameters.value.sort && sortKeysPref.value?.length) {
      sortKeys.value = [...sortKeysPref.value]
    }
  })

  // sort keys change (user click, panel edit) -> URL param + refetch
  watch(
    sortKeys,
    (next) => {
      const sortString = serializeSortKeys(next)
      if (sortString === parameters.value.sort) return
      parameters.value.sort = sortString
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
      sortKeys.value = parseSortParam(next)
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
