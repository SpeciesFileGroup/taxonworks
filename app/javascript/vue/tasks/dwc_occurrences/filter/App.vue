<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="DWC_OCCURRENCE"
      :selected-ids="selectedIds"
      :list="list"
      :button-unify="false"
      :radial-mass-annotator="false"
      :radial-navigator="false"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          ref="filterListRef"
          :list="list"
          :attributes="ATTRIBUTES"
          :backend-sort="true"
          :sortable-keys="sortableKeys"
          :preference-key="`tasks::filters::${DWC_OCCURRENCE}`"
          :radial-annotator="false"
          :radial-navigator="false"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          @remove="({ index }) => list.splice(index, 1)"
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
          title="Hide/show non-frozen columns"
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
import FilterView from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ATTRIBUTES } from './constants/attributes'
import { DWC_OCCURRENCE } from '@/constants/index.js'
import { DwcOcurrence } from '@/routes/endpoints'
import { ref } from 'vue'

const hideFrozen = ref(false)

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
  resetFilter,
  sortableKeys
} = useFilter(DwcOcurrence, {
  sortableColumnsResource: 'dwc_occurrences'
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
  objectType: DWC_OCCURRENCE
})
</script>

<script>
export default {
  name: 'FilterDwcOccurrence'
}
</script>
