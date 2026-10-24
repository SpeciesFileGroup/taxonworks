<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :radial-filter="false"
      :radial-linker="false"
      :radial-mass-annotator="false"
      :radial-navigator="false"
      :button-unify="false"
      v-model="parameters"
      v-model:append="append"
      @filter="handleFilter"
      @per="handleFilter"
      @nextpage="loadPage"
      @reset="handleReset"
    >
      <template #facets>
        <FilterView
          v-model="parameters"
          :annotation-type="annotationType"
          @annotation-type-change="onAnnotationTypeChange"
        />
      </template>
      <template #table>
        <FilterList
          v-if="annotationType"
          :list="list"
          :attributes="currentAttributes"
          :sortable-keys="sortableKeys"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <SortPanel
          v-if="annotationType"
          v-model:sort-keys="sortKeys"
          :labels="currentAttributes"
          :sortable-keys="sortableKeys"
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
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import useAnnotationFilter from './composables/useAnnotationFilter.js'
import { serializeSortKeys, parseSortParam } from '@/helpers/arrays.js'
import { ref, watch } from 'vue'

defineOptions({
  name: 'FilterAnnotations'
})

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
  annotationType,
  currentAttributes,
  setAnnotationType,
  sortableKeys
} = useAnnotationFilter()

const sortKeys = ref(parseSortParam(parameters.value.sort))

// User clicks a column header (or edits SortPanel) -> update the URL param
// and re-request the current page from the server.
watch(
  sortKeys,
  (next) => {
    const sortString = serializeSortKeys(next)
    if (sortString === parameters.value.sort) return
    parameters.value.sort = sortString
    // No type picked or no search yet: the sort applies to the next search.
    if (!annotationType.value || !window.location.search) return
    makeFilterRequest({
      ...parameters.value,
      annotation_type: annotationType.value,
      extend: ['annotated_object'],
      page: 1
    })
  },
  { deep: true }
)

// URL sort param (set by useFilter from the URL after setup, or by browser
// navigation) -> sort indicators.
watch(
  () => parameters.value.sort,
  (next) => {
    if (next === serializeSortKeys(sortKeys.value)) return
    sortKeys.value = parseSortParam(next)
  }
)

function handleFilter() {
  if (!annotationType.value) return

  makeFilterRequest({
    ...parameters.value,
    annotation_type: annotationType.value,
    extend: ['annotated_object'],
    page: 1
  })
}

function handleReset() {
  setAnnotationType(null)
  sortKeys.value = []
  resetFilter()
}

function onAnnotationTypeChange(typeKey) {
  setAnnotationType(typeKey)
  // Sort keys are per-type -- clear when switching to avoid sending a key
  // the new backend doesn't recognize.
  sortKeys.value = []
  parameters.value = { per: parameters.value.per }
}
</script>
