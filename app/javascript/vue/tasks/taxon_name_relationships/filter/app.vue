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
          ref="filterListRef"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
          :sortable-keys="sortableKeys"
          :attributes="ATTRIBUTES"
          :list="list"
          :preference-key="`tasks::filters::${TAXON_NAME_RELATIONSHIP}`"
        />
      </template>
      <template #nav-settings-start>
        <SortPanel
          v-model:sort-keys="sortKeys"
          :labels="ATTRIBUTES"
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
import FilterComponent from './components/filter.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialTaxonNameRelationship from '@/components/radials/taxon_name_relationship/radial.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import { listParser } from '../utils/listParser.js'
import { TAXON_NAME_RELATIONSHIP } from '@/constants/index.js'
import { TaxonNameRelationship } from '@/routes/endpoints'
import { ATTRIBUTES } from './constants/attributes'
import { ref } from 'vue'

defineOptions({
  name: 'FilterTaxonNameRelationships'
})

const hideFrozen = ref(false)

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
} = useFilter(TaxonNameRelationship, {
  listParser,
  sortableColumnsResource: 'taxon_name_relationships'
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
  objectType: TAXON_NAME_RELATIONSHIP
})
</script>
