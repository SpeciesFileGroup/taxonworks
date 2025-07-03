<template>
  <div>
    <h1>Filter taxon name relationships</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="TAXON_NAME_RELATIONSHIP"
      :list="list"
      :selected-ids="selectedIds"
      :button-unify="false"
      :radial-linker="true"
      :radial-navigator="false"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, page: 1 })"
      @per="makeFilterRequest({ ...parameters, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :attributes="ATTRIBUTES"
          :list="list"
          @on-sort="(sorted) => (list = sorted)"
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
import FilterComponent from './components/filter.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { listParser } from '../utils/listParser.js'
import { TAXON_NAME_RELATIONSHIP } from '@/constants/index.js'
import { TaxonNameRelationship } from '@/routes/endpoints'
import { computed } from 'vue'
import { ATTRIBUTES } from './constants/attributes'

defineOptions({
  name: 'FilterTaxonNameRelationships'
})

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
} = useFilter(TaxonNameRelationship, { listParser })
</script>
