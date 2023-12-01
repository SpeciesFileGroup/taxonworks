<template>
  <div>
    <h1>Filter loans</h1>

    <FilterLayout
      :list="list"
      :url-request="urlRequest"
      :object-type="LOAN"
      :pagination="pagination"
      v-model="parameters"
      :selected-ids="selectedIds"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :list="list"
          :attributes="ATTRIBUTES"
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
import VSpinner from '@/components/spinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { ATTRIBUTES } from './constants/attributes'
import { Loan } from '@/routes/endpoints'
import { LOAN } from '@/constants/index.js'

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
} = useFilter(Loan)
</script>

<script>
export default {
  name: 'FilterLoans'
}
</script>
