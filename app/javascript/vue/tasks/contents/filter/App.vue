<template>
  <div>
    <h1>Filter contents</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="CONTENT"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :radial-navigator="false"
      :extend-download="tsvDownload"
      only-extend-download
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
          v-model="selectedIds"
          :attributes="ATTRIBUTES"
          :list="list"
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
import { computed } from 'vue'
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterView from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import TsvDownload from './components/TsvDownload.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { listParser } from './utils/listParser'
import { ATTRIBUTES } from './constants/attributes'
import { Content } from '@/routes/endpoints'
import { CONTENT } from '@/constants/index.js'

const extend = ['otu', 'topic']

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
} = useFilter(Content, { listParser, initParameters: { extend } })

const tsvDownload = computed(() => [
  {
    label: 'TSV',
    component: TsvDownload,
    bind: {
      params: parameters.value,
      selectedList: selectedIds.value,
      pagination: pagination.value
    }
  }
])
</script>

<script>
export default {
  name: 'FilterContents'
}
</script>
