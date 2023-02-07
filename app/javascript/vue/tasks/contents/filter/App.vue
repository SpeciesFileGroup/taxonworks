<template>
  <div>
    <h1>Filter contents</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="CONTENT"
      :selected-ids="selectedIds"
      :list="list"
      v-model="parameters"
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
import { Content } from 'routes/endpoints'
import { CONTENT } from 'constants/index.js'

const extend = ['otu', 'topic']

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
} = useFilter(Content, { listParser, initParameters: { extend } })
</script>

<script>
export default {
  name: 'FilterContents'
}
</script>
