<template>
  <div>
    <h1>Filter field occurrences</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="FIELD_OCCURRENCE"
      :selected-ids="selectedIds"
      :list="list"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #nav-right>
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
      </template>
      <template #table>
        <FilterList
          :list="list"
          :layout="currentLayout"
          v-model="selectedIds"
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
import FilterView from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import TableLayoutSelector from '@/components/Filter/Table/TableLayoutSelector.vue'
import { LAYOUTS } from './constants/layouts'
import { listParser } from './utils/listParser'
import { FIELD_OCCURRENCE } from '@/constants/index.js'
import { FieldOccurrence } from '@/routes/endpoints'
import { useTableLayoutConfiguration } from '@/components/Filter/composables/useTableLayoutConfiguration.js'

defineOptions({
  name: 'FilterFieldOccurrences'
})

const extend = [
  'collecting_event',
  'taxon_determinations',
  'identifiers',
  'dwc_occurrence'
]

const {
  currentLayout,
  includes,
  layouts,
  properties,
  updatePropertiesPositions,
  saveLayoutPreferences,
  resetPreferences,
  forceUpdatePreference
} = useTableLayoutConfiguration({ layouts: LAYOUTS, model: FIELD_OCCURRENCE })

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
} = useFilter(FieldOccurrence, { listParser, initParameters: { extend } })
</script>
