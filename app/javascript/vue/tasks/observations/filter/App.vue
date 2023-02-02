<template>
  <div>
    <h1>Filter observations</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="OBSERVATION"
      :selected-ids="selectedIds"
      :list="list"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <TagAll
          class="circle-button"
          :ids="selectedIds"
          :type="OBSERVATION"
        />
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="csvList" />
      </template>
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
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import { listParser } from './utils/listParser'
import { ATTRIBUTES } from './constants/attributes'
import { Observation } from 'routes/endpoints'
import { OBSERVATION } from 'constants/index.js'
import { computed, ref } from 'vue'

const extend = ['observation_object']
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
} = useFilter(Observation, { listParser, initParameters: { extend } })

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)
</script>

<script>
export default {
  name: 'FilterObservations'
}
</script>
