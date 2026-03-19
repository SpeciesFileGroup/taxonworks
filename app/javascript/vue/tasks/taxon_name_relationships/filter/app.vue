<template>
  <div class="margin-medium-top">
    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="TAXON_NAME_RELATIONSHIP"
      :list="list"
      :selected-ids="sortedSelectedIds"
      :button-unify="false"
      :radial-navigator="false"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, page: 1 })"
      @per="makeFilterRequest({ ...parameters, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <RadialTaxonNameRelationship
          :ids="sortedSelectedIds"
          :disabled="!sortedSelectedIds.length"
          :count="sortedSelectedIds.length"
          @update="() => makeFilterRequest({ ...parameters, page: 1 })"
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
import RadialTaxonNameRelationship from '@/components/radials/taxon_name_relationship/radial.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { listParser } from '../utils/listParser.js'
import { TAXON_NAME_RELATIONSHIP } from '@/constants/index.js'
import { TaxonNameRelationship } from '@/routes/endpoints'
import { ATTRIBUTES } from './constants/attributes'

defineOptions({
  name: 'FilterTaxonNameRelationships'
})

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
} = useFilter(TaxonNameRelationship, { listParser })
</script>
