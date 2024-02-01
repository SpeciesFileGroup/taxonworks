<template>
  <div>
    <h1>Filter biological associations</h1>

    <FilterLayout
      :pagination="pagination"
      v-model="parameters"
      :object-type="BIOLOGICAL_ASSOCIATION"
      :selected-ids="selectedIds"
      :list="list"
      :url-request="urlRequest"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialBiologicalAssociation
          :disabled="!list.length"
          :parameters="parameters"
          :count="pagination?.total || 0"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #nav-right>
        <div class="horizontal-right-content gap-small">
          <RadialBiologicalAssociation
            :disabled="!list.length"
            :ids="selectedIds"
            :count="selectedIds.length"
            @update="
              () => makeFilterRequest({ ...parameters, extend, page: 1 })
            "
          />
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :attributes="ATTRIBUTES"
          :header-groups="HEADERS"
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
import useFilter from '@/shared/Filter/composition/useFilter.js'
import VSpinner from '@/components/spinner.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import RadialBiologicalAssociation from '@/components/radials/BiologicalAssociation/radial.vue'
import { listParser } from './utils/listParser'
import { BIOLOGICAL_ASSOCIATION } from '@/constants/index.js'
import { BiologicalAssociation } from '@/routes/endpoints'
import { ATTRIBUTES } from './constants/attributes.js'

const HEADERS = [
  {
    title: 'Subject',
    colspan: 5,
    scope: 'colgroup'
  },
  {
    colspan: 1
  },
  {
    title: 'Object',
    colspan: 5,
    scope: 'colgroup'
  }
]

const extend = [
  'object',
  'subject',
  'biological_relationship',
  'taxonomy',
  'biological_relationship_types'
]

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
} = useFilter(BiologicalAssociation, { listParser, initParameters: { extend } })
</script>

<script>
export default {
  name: 'FilterBiologicalAssociations'
}
</script>
