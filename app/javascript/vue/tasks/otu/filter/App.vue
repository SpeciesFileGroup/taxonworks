<template>
  <div>
    <h1>Filter OTUs</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="OTU"
      :selected-ids="selectedIds"
      :extend-download="extendDownload"
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
          :object-type="OTU"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #nav-right>
        <RadialOtu
          :disabled="!list.length"
          :ids="selectedIds"
          :count="selectedIds.length"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
        <RadialMatrix
          :object-type="OTU"
          :disabled="!list.length"
          :ids="selectedIds"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          :list="list"
          :attributes="ATTRIBUTES"
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
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import RadialOtu from '@/components/radials/otu/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { OTU } from '@/constants/index.js'
import { Otu } from '@/routes/endpoints'
import { computed } from 'vue'
import csvDownload from './components/csvDownload.vue'

const extend = ['taxonomy']

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
} = useFilter(Otu, { listParser, initParameters: { extend } })

const extendDownload = computed(() => [
  {
    label: 'CSV',
    component: csvDownload,
    bind: {
      params: parameters.value
    }
  }
])
</script>

<script>
export default {
  name: 'FilterOTU'
}
</script>
