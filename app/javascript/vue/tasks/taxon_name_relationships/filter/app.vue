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
      :radial-linker="false"
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
        <ListResults
          v-model="selectedIds"
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
import FilterComponent from './components/filter.vue'
import ListResults from './components/ListResults.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import { TAXON_NAME_RELATIONSHIP } from '@/constants/index.js'
import { TaxonNameRelationship } from '@/routes/endpoints'

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
} = useFilter(TaxonNameRelationship)
</script>

<script>
export default {
  name: 'FilterTaxonNameRelationships'
}
</script>
