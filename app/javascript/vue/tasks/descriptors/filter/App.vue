<template>
  <div>
    <h1>Filter descriptors</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="DESCRIPTOR"
      :selected-ids="selectedIds"
      :list="list"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialMatrix
          :disabled="!list.length"
          :parameters="parameters"
          :object-type="DESCRIPTOR"
        />
      </template>
      <template #nav-right>
        <RadialMatrix
          :ids="selectedIds"
          :disabled="!list.length"
          :object-type="DESCRIPTOR"
        />
      </template>
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
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import VSpinner from '@/components/spinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { listParser } from './utils/listParser'
import { ATTRIBUTES } from './constants/attributes'
import { Descriptor } from '@/routes/endpoints'
import { DESCRIPTOR } from '@/constants/index.js'

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
} = useFilter(Descriptor, { listParser })
</script>

<script>
export default {
  name: 'FilterDescriptors'
}
</script>
