<template>
  <div>
    <h1>Filter loans</h1>

    <FilterLayout
      :list="list"
      :url-request="urlRequest"
      :object-type="LOAN"
      :pagination="pagination"
      v-model="parameters"
      :selected-ids="selectedIds"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <TagAll
          :ids="selectedIds"
          :type="LOAN"
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
import FilterView from './components/FilterView.vue'
import FilterList from 'components/layout/Filter/FilterList.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import { ATTRIBUTES } from './constants/attributes'
import { Loan } from 'routes/endpoints'
import { LOAN } from 'constants/index.js'
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
} = useFilter(Loan)

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)
</script>

<script>
export default {
  name: 'FilterLoans'
}
</script>
