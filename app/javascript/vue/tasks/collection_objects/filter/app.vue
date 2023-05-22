<template>
  <div>
    <h1>Filter collection objects</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :selected-ids="selectedIds"
      :object-type="COLLECTION_OBJECT"
      :list="list"
      :extend-download="extendDownload"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialLoan
          :disabled="!list.length"
          :parameters="parameters"
        />
        <RadialMatrix
          :disabled="!list.length"
          :parameters="parameters"
          :object-type="COLLECTION_OBJECT"
        />
      </template>
      <template #nav-right>
        <div class="horizontal-right-content">
          <RadialLoan
            :disabled="!list.length"
            :ids="selectedIds"
          />
          <RadialMatrix
            :ids="selectedIds"
            :disabled="!list.length"
            :object-type="COLLECTION_OBJECT"
          />
          <DeleteCollectionObjects
            :ids="selectedIds"
            :disabled="!selectedIds.length"
            @delete="removeCOFromList"
          />
          <span class="separate-left separate-right">|</span>

          <LayoutConfiguration />
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <ListComponent
          v-model="selectedIds"
          :list="list"
          :layout="currentLayout"
          @on-sort="list = $event"
        />
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
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import DwcDownload from './components/dwcDownload.vue'
import DeleteCollectionObjects from './components/DeleteCollectionObjects.vue'
import VSpinner from 'components/spinner.vue'
import LayoutConfiguration from './components/Layout/LayoutConfiguration.vue'
import RadialLoan from 'components/radials/loan/radial.vue'
import RadialMatrix from 'components/radials/matrix/radial.vue'
import { computed } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import { COLLECTION_OBJECT } from 'constants/index.js'
import { useLayoutConfiguration } from './components/Layout/useLayoutConfiguration'
import { LAYOUTS } from './constants/layouts.js'
import { listParser } from './utils/listParser.js'

const extend = [
  'dwc_occurrence',
  'repository',
  'current_repository',
  'data_attributes',
  'collecting_event',
  'taxon_determinations',
  'identifiers'
]

const { currentLayout } = useLayoutConfiguration(LAYOUTS)

const {
  isLoading,
  list,
  pagination,
  append,
  urlRequest,
  loadPage,
  parameters,
  selectedIds,
  makeFilterRequest,
  resetFilter
} = useFilter(CollectionObject, { initParameters: { extend }, listParser })

const extendDownload = computed(() => [
  {
    label: 'DwC',
    component: DwcDownload,
    bind: {
      params: parameters.value,
      total: pagination.value?.total,
      selectedIds: selectedIds.value
    }
  }
])

function removeCOFromList(ids) {
  list.value = list.value.filter((item) => !ids.includes(item.id))
  selectedIds.value = selectedIds.value.filter((id) => !ids.includes(id))
}
</script>

<script>
export default {
  name: 'FilterCollectionObjects'
}
</script>
