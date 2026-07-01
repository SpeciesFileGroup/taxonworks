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
          ref="filterListRef"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
          :sortable-keys="sortableKeys"
          :attributes="ATTRIBUTES"
          :header-groups="HEADERS"
          :list="list"
          v-model:hide-unfrozen="hideFrozen"
          :preference-key="`tasks::filters::${BIOLOGICAL_ASSOCIATION}`"
          radial-object
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <SortPanel
          v-model:sort-keys="sortKeys"
          :labels="sortLabels"
          :sortable-keys="sortableKeys"
        />
        <SaveViewButton
          v-if="hasUnsavedChanges"
          @save="saveViewAsDefault"
        />
        <VToggle
          v-model="hideFrozen"
          title="Hide non-frozen columns"
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
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import RadialBiologicalAssociation from '@/components/radials/BiologicalAssociation/radial.vue'
import { listParser } from './utils/listParser'
import { BIOLOGICAL_ASSOCIATION } from '@/constants/index.js'
import { BiologicalAssociation } from '@/routes/endpoints'
import { ATTRIBUTES } from './constants/attributes.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import { computed, ref } from 'vue'

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
  urlRequest,
  sortableKeys
} = useFilter(BiologicalAssociation, {
  listParser,
  initParameters: { extend },
  sortableColumnsResource: 'biological_associations'
})

const {
  sortKeys,
  unsavedViewChanges,
  hasUnsavedChanges,
  filterListRef,
  saveViewAsDefault
} = useFilterView({
  parameters,
  makeFilterRequest,
  objectType: BIOLOGICAL_ASSOCIATION,
  extend
})

const sortLabels = computed(() => {
  const map = {}
  for (const [key, label] of Object.entries(ATTRIBUTES)) {
    let side = null
    if (key.startsWith('subject_') || key.endsWith('_subject')) side = 'Subject'
    else if (key.startsWith('object_') || key.endsWith('_object')) side = 'Object'
    map[key] = side ? `${side} · ${label}` : label
  }
  return map
})
</script>

<script>
export default {
  name: 'FilterBiologicalAssociations'
}
</script>
