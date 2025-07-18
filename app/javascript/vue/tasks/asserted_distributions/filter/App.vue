<template>
  <div>
    <h1>Filter asserted distributions</h1>

    <FilterLayout
      :pagination="pagination"
      :selected-ids="sortedSelectedIds"
      :object-type="ASSERTED_DISTRIBUTION"
      :list="list"
      :url-request="urlRequest"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialAssertedDistribution
          :disabled="!list.length"
          :parameters="parameters"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #nav-right>
        <RadialAssertedDistribution
          :disabled="!list.length"
          :ids="sortedSelectedIds"
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
        >
          <template #otuGlobalId="{ value, setHighlight }">
            <RadialObject
              :global-id="value"
              @click="setHighlight"
            />
          </template>
        </FilterList>
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
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import RadialAssertedDistribution from '@/components/radials/asserted_distribution/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { AssertedDistribution } from '@/routes/endpoints'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'

const extend = ['otu', 'citations', 'asserted_distribution_shape', 'taxonomy']

defineOptions({
  name: 'FilterAssertedDistributions'
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
} = useFilter(AssertedDistribution, { listParser, initParameters: { extend } })
</script>
