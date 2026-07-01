<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="OTU"
      :selected-ids="sortedSelectedIds"
      :extend-download="extendDownload"
      :list="list"
      only-extend-download
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialMatrix
          :parameters="parameters"
          :disabled="!list.length"
          :object-type="OTU"
          use-new-key-slice
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
      </template>
      <template #nav-right>
        <RadialOtu
          :disabled="!list.length"
          :ids="sortedSelectedIds"
          :count="sortedSelectedIds.length"
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
        <RadialMatrix
          :object-type="OTU"
          :disabled="!list.length"
          :ids="sortedSelectedIds"
          use-new-key-slice
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
      </template>
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          ref="filterListRef"
          :list="list"
          :attributes="ATTRIBUTES"
          :sortable-keys="sortableKeys"
          :preference-key="`tasks::filters::${OTU}`"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
          radial-object
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <SortPanel
          v-model:sort-keys="sortKeys"
          :labels="ATTRIBUTES"
          :sortable-keys="sortableKeys"
        />
        <SaveViewButton
          v-if="hasUnsavedChanges"
          @save="saveViewAsDefault"
        />
        <VToggle
          v-model="hideFrozen"
          title="Hide non-frozen columns"
        >
          <VIcon
            :name="hideFrozen ? 'contract' : 'expand'"
            x-small
          />
        </VToggle>
      </template>
    </FilterLayout>
    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px' }"
    />
  </div>
</template>

<script setup>
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterView from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { serializeSortKeys, parseSortParam } from '@/helpers/arrays.js'
import { useUserPreference } from '@/composables'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import RadialOtu from '@/components/radials/otu/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { OTU } from '@/constants/index.js'
import { Otu } from '@/routes/endpoints'
import { computed, onMounted, ref, useTemplateRef, watch } from 'vue'
import csvDownload from './components/csvDownload.vue'
import DwcChecklistDownload from './components/dwcChecklistDownload.vue'

const extend = ['taxonomy']
const hideFrozen = ref(false)

const {
  append,
  isLoading,
  list,
  loadPage,
  makeFilterRequest,
  pagination,
  parameters,
  resetFilter,
  selectedIds,
  sortedSelectedIds,
  urlRequest,
  sortableKeys
} = useFilter(Otu, {
  listParser,
  initParameters: { extend },
  sortableColumnsResource: 'otus'
})

const sortKeysPref = useUserPreference(
  `tasks::filters::${OTU}::sortKeys`,
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

watch(
  sortKeys,
  (next) => {
    const sortString = serializeSortKeys(next)
    if (sortString === parameters.value.sort) return
    parameters.value.sort = sortString
    makeFilterRequest({ ...parameters.value, extend, page: 1 })
  },
  { deep: true }
)

watch(
  () => parameters.value.sort,
  (next) => {
    if (next === serializeSortKeys(sortKeys.value)) return
    sortKeys.value = parseSortParam(next)
  }
)

function sortKeysEqual(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b)) return false
  if (a.length !== b.length) return false
  for (let i = 0; i < a.length; i++) {
    if (a[i]?.key !== b[i]?.key || a[i]?.dir !== b[i]?.dir) return false
  }
  return true
}

const hasUnsavedSortChanges = computed(() =>
  !sortKeysEqual(sortKeys.value, sortKeysPref.value ?? [])
)

const hasUnsavedChanges = computed(
  () => hasUnsavedSortChanges.value || unsavedViewChanges.value
)

function saveViewAsDefault() {
  filterListRef.value?.saveViewAsDefault()
  sortKeysPref.value = JSON.parse(JSON.stringify(sortKeys.value))
}

const extendDownload = computed(() => [
  {
    label: 'TSV',
    component: csvDownload,
    bind: {
      params: parameters.value
    }
  },
  {
    label: 'DwC Checklist',
    component: DwcChecklistDownload,
    bind: {
      params: parameters.value,
      total: pagination.value?.total,
      selectedIds: selectedIds.value
    }
  }
])
</script>

<script>
export default {
  name: 'FilterOTU'
}
</script>
