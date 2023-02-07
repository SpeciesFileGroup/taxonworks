<template>
  <div>
    <h1>Filter observations</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="OBSERVATION"
      :selected-ids="selectedIds"
      :list="list"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :attributes="ATTRIBUTES"
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
import FilterView from './components/FilterView.vue'
import FilterList from 'components/layout/Filter/FilterList.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import { listParser } from './utils/listParser'
import { ATTRIBUTES } from './constants/attributes'
import { Observation } from 'routes/endpoints'
import { OBSERVATION } from 'constants/index.js'
import { ref } from 'vue'

const extend = ['observation_object']
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
} = useFilter(Observation, { listParser, initParameters: { extend } })
</script>

<script>
export default {
  name: 'FilterObservations'
}
</script>
