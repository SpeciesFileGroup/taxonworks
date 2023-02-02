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
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <TagAll
          class="circle-button"
          :ids="selectedIds"
          type="Extract"
        />
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="csvList" />
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
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import FilterComponent from './components/Filter.vue'
import FilterList from 'components/layout/Filter/FilterList.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import extend from 'tasks/extracts/new_extract/const/extendRequest'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import { ATTRIBUTES } from './constants/attributes'
import { EXTRACT } from 'constants/index.js'
import { Extract } from 'routes/endpoints'
import { computed, ref } from 'vue'

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
} = useFilter(Extract, { initParameters: { extend } })

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)
</script>

<script>
export default {
  name: 'FilterExtracts'
}
</script>
