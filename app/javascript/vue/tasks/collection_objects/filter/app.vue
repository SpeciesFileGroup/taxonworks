<template>
  <div>
    <h1>Filter collection objects</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :selected-ids="sortedSelectedIds"
      :object-type="COLLECTION_OBJECT"
      :list="list"
      :extend-download="extendDownload"
      :csv-options="csvOptions"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, exclude, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, exclude, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialCollectionObject
          :disabled="!list.length"
          :parameters="parameters"
          :count="pagination?.total || 0"
          @update="() => makeFilterRequest({ ...parameters, extend, exclude })"
        />
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
        <div class="horizontal-right-content gap-small">
          <RadialCollectionObject
            :disabled="!list.length"
            :ids="sortedSelectedIds"
            :count="sortedSelectedIds.length"
            @update="
              () => makeFilterRequest({ ...parameters, extend, exclude })
            "
          />
          <RadialLoan
            :disabled="!list.length"
            :ids="sortedSelectedIds"
          />
          <RadialMatrix
            :ids="sortedSelectedIds"
            :disabled="!list.length"
            :object-type="COLLECTION_OBJECT"
          />
          <DeleteCollectionObjects
            :ids="sortedSelectedIds"
            :disabled="!sortedSelectedIds.length"
            @delete="removeCOFromList"
          />
          <span class="separate-left separate-right">|</span>
          <TableLayoutSelector
            v-model="currentLayout"
            v-model:includes="includes"
            v-model:properties="properties"
            :layouts="layouts"
            @reset="resetPreferences"
            @sort="updatePropertiesPositions"
            @sort:column="forceUpdatePreference"
            @update="saveLayoutPreferences"
          />
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <TableResults
          v-model="selectedIds"
          :list="list"
          :layout="currentLayout"
          radial-object
          @on-sort="list = $event"
          @remove="({ index }) => list.splice(index, 1)"
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
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterComponent from './components/filter.vue'
import TableResults from '@/components/Filter/Table/TableResults.vue'
import DwcDownload from './components/dwcDownload.vue'
import DeleteCollectionObjects from './components/DeleteCollectionObjects.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import TableLayoutSelector from '@/components/Filter/Table/TableLayoutSelector.vue'
import RadialLoan from '@/components/radials/loan/radial.vue'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import RadialCollectionObject from '@/components/radials/co/radial.vue'
import { computed } from 'vue'
import { CollectionObject } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants/index.js'
import { useTableLayoutConfiguration } from '@/components/Filter/composables/useTableLayoutConfiguration.js'
import { LAYOUTS } from './constants/layouts.js'
import { listParser } from './utils/listParser.js'
import { useCSVOptions, useFilter } from '@/shared/Filter/composition'

const extend = [
  'dwc_occurrence',
  'repository',
  'current_repository',
  'collecting_event',
  'taxon_determinations',
  'identifiers',
  'container_item',
  'container'
]

const exclude = ['object_labels']

const {
  currentLayout,
  includes,
  layouts,
  properties,
  updatePropertiesPositions,
  saveLayoutPreferences,
  resetPreferences,
  forceUpdatePreference
} = useTableLayoutConfiguration({ layouts: LAYOUTS, model: COLLECTION_OBJECT })

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
  urlRequest
} = useFilter(CollectionObject, {
  initParameters: { extend, exclude },
  listParser
})

const csvOptions = useCSVOptions({ layout: currentLayout, list })

const extendDownload = computed(() => [
  {
    label: 'DwC',
    component: DwcDownload,
    bind: {
      params: parameters.value,
      total: pagination.value?.total,
      selectedIds: selectedIds.value,
      nestParameter: 'collection_object_query'
    }
  }
])

function removeCOFromList(ids) {
  L
  list.value = list.value.filter((item) => !ids.includes(item.id))
  selectedIds.value = selectedIds.value.filter((id) => !ids.includes(id))
}
</script>

<script>
export default {
  name: 'FilterCollectionObjects'
}
</script>
