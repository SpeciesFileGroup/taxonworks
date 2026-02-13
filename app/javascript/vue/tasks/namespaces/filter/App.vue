<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="NAMESPACE"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :radial-navigator="false"
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
      <template #table>
        <FilterList
          :list="list"
          :attributes="ATTRIBUTES"
          v-model="selectedIds"
          @on-sort="(items) => (list = items)"
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
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { NAMESPACE } from '@/constants/index.js'
import { Namespace } from '@/routes/endpoints'

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
} = useFilter(Namespace, { listParser })
</script>

<script>
export default {
  name: 'FilterNamespace'
}
</script>
