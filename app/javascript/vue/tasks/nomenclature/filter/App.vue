<template>
  <div>
    <h1>Filter nomenclature</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :selected-ids="selectedIds"
      :object-type="TAXON_NAME"
      :list="list"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <RadialLabel
          :object-type="TAXON_NAME"
          :ids="selectedIds"
          :disabled="!selectedIds.length"
        />
        <span class="separate-left separate-right">|</span>
        <CsvButton
          :list="csvList"
          :options="{ fields }"
        />
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
import FilterList from 'components/layout/Filter/FilterList.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import RadialLabel from 'components/radials/label/radial.vue'
import { ATTRIBUTES } from './constants/attributes.js'
import { listParser } from './utils/listParser'
import { TaxonName } from 'routes/endpoints'
import { ref, computed } from 'vue'
import { TAXON_NAME } from 'constants/index.js'

const extend = ['parent']

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
} = useFilter(TaxonName, { listParser, initParameters: { extend } })

const selectedIds = ref([])

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)
</script>

<script>
export default {
  name: 'FilterNomenclature'
}
</script>
