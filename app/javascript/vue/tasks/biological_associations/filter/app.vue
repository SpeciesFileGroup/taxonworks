<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      v-model="parameters"
      :object-type="BIOLOGICAL_ASSOCIATION"
      :selected-ids="sortedSelectedIds"
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
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
      </template>
      <template #nav-right>
        <div class="horizontal-right-content gap-small">
          <RadialBiologicalAssociation
            :disabled="!list.length"
            :ids="sortedSelectedIds"
            :count="sortedSelectedIds.length"
            @update="() => makeFilterRequest({ ...parameters, extend })"
          />
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          :backend-sort="true"
          :attributes="ATTRIBUTES"
          :header-groups="HEADERS"
          :list="list"
          :hide-unfrozen="hideFrozen"
          :preference-key="`tasks::filters::${BIOLOGICAL_ASSOCIATION}`"
          radial-object
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <VToggle
          title="Hide/show non-frozen columns"
          @click="() => (hideFrozen = !hideFrozen)"
        >
          <VIcon
            :name="hideFrozen ? 'contract' : 'expand'"
            x-small
          />
        </VToggle>
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
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import RadialBiologicalAssociation from '@/components/radials/BiologicalAssociation/radial.vue'
import { listParser } from './utils/listParser'
import { BIOLOGICAL_ASSOCIATION } from '@/constants/index.js'
import { BiologicalAssociation } from '@/routes/endpoints'
import { ATTRIBUTES } from './constants/attributes.js'
import { serializeSortKeys, parseSortParam } from '@/helpers/arrays.js'
import { ref, watch } from 'vue'

const hideFrozen = ref(false)

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
} = useFilter(BiologicalAssociation, { listParser, initParameters: { extend } })

const sortKeys = ref(parseSortParam(parameters.value.sort))

// Sort changes coming from the table -> update query param + re-fetch.
watch(
  sortKeys,
  (next) => {
    const sortString = serializeSortKeys(next)
    if (sortString === parameters.value.sort) return
    parameters.value.sort = sortString
    makeFilterRequest({ ...parameters.value, extend, page: 1 })
  },
  { deep: true }
)

// URL/external changes to parameters.sort -> hydrate the table.
watch(
  () => parameters.value.sort,
  (next) => {
    if (next === serializeSortKeys(sortKeys.value)) return
    sortKeys.value = parseSortParam(next)
  }
)
</script>

<script>
export default {
  name: 'FilterBiologicalAssociations'
}
</script>
