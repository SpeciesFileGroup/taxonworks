<template>
  <div>
    <h1>Filter asserted distributions</h1>

    <FilterLayout
      :pagination="pagination"
      :selected-ids="selectedIds"
      :object-type="ASSERTED_DISTRIBUTION"
      :list="list"
      :url-request="urlRequest"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="csvList" />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
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
import FilterComponent from './components/FilterView.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import FilterList from 'components/layout/Filter/FilterList.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { AssertedDistribution } from 'routes/endpoints'
import { computed, ref } from 'vue'
import { ASSERTED_DISTRIBUTION } from 'constants/index.js'

const extend = ['otu', 'citations', 'geographic_area', 'taxonomy']

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
} = useFilter(AssertedDistribution, { listParser, initParameters: { extend } })

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)
</script>

<script>
export default {
  name: 'FilterAssertedDistributions'
}
</script>
