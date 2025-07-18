<template>
  <div>
    <h1>Filter taxon names</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :selected-ids="sortedSelectedIds"
      :object-type="TAXON_NAME"
      :list="list"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialNomenclature
          :disabled="!list.length"
          :parameters="parameters"
          :count="pagination?.total || 0"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #nav-right>
        <RadialLabel
          :object-type="TAXON_NAME"
          :ids="sortedSelectedIds"
          :disabled="!sortedSelectedIds.length"
        />
        <RadialNomenclature
          :disabled="!list.length"
          :ids="sortedSelectedIds"
          :count="sortedSelectedIds.length"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
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
import FilterComponent from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import RadialLabel from '@/components/radials/label/radial.vue'
import RadialNomenclature from '@/components/radials/nomenclature/radial.vue'
import { ATTRIBUTES } from './constants/attributes.js'
import { listParser } from './utils/listParser'
import { TaxonName } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants/index.js'

const extend = ['parent', 'valid_name']

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
} = useFilter(TaxonName, { listParser, initParameters: { extend } })
</script>

<script>
export default {
  name: 'FilterNomenclature'
}
</script>
