<template>
  <div>
    <h1>Filter extracts</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="EXTRACT"
      :selected-ids="selectedIds"
      :list="list"
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
          :object-type="EXTRACT"
        />
      </template>
      <template #nav-right>
        <RadialMatrix
          :ids="selectedIds"
          :disabled="!list.length"
          :object-type="EXTRACT"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :list="list"
          :attributes="ATTRIBUTES"
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
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterComponent from './components/Filter.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import VSpinner from '@/components/spinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import extend from '@/tasks/extracts/new_extract/const/extendRequest'
import { ATTRIBUTES } from './constants/attributes'
import { EXTRACT } from '@/constants/index.js'
import { Extract } from '@/routes/endpoints'

const {
  isLoading,
  list,
  pagination,
  append,
  urlRequest,
  loadPage,
  selectedIds,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter(Extract, { initParameters: { extend } })
</script>

<script>
export default {
  name: 'FilterExtracts'
}
</script>
