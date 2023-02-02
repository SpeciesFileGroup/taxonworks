<template>
  <div>
    <h1>Filter biological associations</h1>

    <FilterLayout
      :pagination="pagination"
      v-model="parameters"
      :object-type="BIOLOGICAL_ASSOCIATION"
      :selected-ids="selectedIds"
      :list="list"
      :url-request="urlRequest"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="csvFields" />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :attributes="ATTRIBUTES"
          :header-groups="HEADERS"
          :list="list"
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
import FilterComponent from './components/FilterView.vue'
import CsvButton from 'components/csvButton'
import useFilter from 'shared/Filter/composition/useFilter.js'
import VSpinner from 'components/spinner.vue'
import FilterList from 'components/layout/Filter/FilterList.vue'
import { listParser } from './utils/listParser'
import { BIOLOGICAL_ASSOCIATION } from 'constants/index.js'
import { BiologicalAssociation } from 'routes/endpoints'
import { computed, ref } from 'vue'
import { ATTRIBUTES } from './constants/attributes.js'

const HEADERS = [
  {
    colspan: 2
  },
  {
    title: 'Subject',
    colspan: 5,
    scope: 'colgroup'
  },
  {
    colspan: 1
  },
  {
    title: 'Object',
    colspan: 5,
    scope: 'colgroup'
  }
]

const extend = [
  'object',
  'subject',
  'biological_relationship',
  'taxonomy',
  'biological_relationship_types'
]

const csvFields = computed(() => (selectedIds.value.length ? list.value : []))
const selectedIds = ref([])

const {
  isLoading,
  list,
  pagination,
  append,
  urlRequest,
  loadPage,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter(BiologicalAssociation, { listParser, initParameters: { extend } })
</script>

<script>
export default {
  name: 'FilterBiologicalAssociations'
}
</script>
