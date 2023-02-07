<template>
  <div>
    <h1>Filter sources</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="SOURCE"
      :selected-ids="selectedIds"
      :list="list"
      :extend-download="extendDownload"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <ListComponent
          v-model="selectedIds"
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
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import BibtexButton from './components/bibtex'
import BibliographyButton from './components/bibliography.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import { Source } from 'routes/endpoints'
import { SOURCE } from 'constants/index.js'
import { computed } from 'vue'

const extend = ['documents']

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
} = useFilter(Source, { initParameters: { extend } })

const extendDownload = computed(() => [
  {
    label: 'BibTeX',
    component: BibtexButton,
    bind: {
      selectedList: selectedIds.value,
      pagination: pagination.value,
      params: parameters.value
    }
  },
  {
    label: 'Download formatted',
    component: BibliographyButton,
    bind: {
      selectedList: selectedIds.value,
      pagination: pagination.value,
      params: parameters.value
    }
  }
])
</script>

<script>
export default {
  name: 'FilterSources'
}
</script>
