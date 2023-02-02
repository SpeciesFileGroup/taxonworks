<template>
  <div>
    <h1>Filter OTUs</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="OTU"
      :selected-ids="selectedIds"
      :list="list"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="csvFields" />
      </template>
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width overflow-x-auto">
          <FilterList
            :list="list"
            :attributes="ATTRIBUTES"
            v-model="selectedIds"
            @on-sort="list = $event"
          />
        </div>
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
import CsvButton from 'components/csvButton'
import useFilter from 'shared/Filter/composition/useFilter.js'
import VSpinner from 'components/spinner.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { OTU } from 'constants/index.js'
import { Otu } from 'routes/endpoints'
import { computed, ref } from 'vue'

const extend = ['taxonomy']

const csvFields = computed(() => (selectedIds.value.length ? list.value : []))
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
} = useFilter(Otu, { listParser, initParameters: { extend } })
</script>

<script>
export default {
  name: 'FilterOTU'
}
</script>
