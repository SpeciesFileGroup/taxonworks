<template>
  <div>
    <h1>Filter anatomical parts</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="ANATOMICAL_PART"
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
      <template #nav-query-right>
        <RadialMatrix
          :parameters="parameters"
          :disabled="!list.length"
          :object-type="ANATOMICAL_PART"
        />
      </template>
      <template #nav-right>
        <RadialMatrix
          :ids="sortedSelectedIds"
          :disabled="!list.length"
          :object-type="ANATOMICAL_PART"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #above-table>
        <floatGraph
          v-if="idForGraph"
          :load-params="{ anatomical_part_id: idForGraph }"
          show-close
          @close="() => (idForGraph = null)"
        />
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
          :preference-key="`tasks::filters::${ANATOMICAL_PART}`"
          :radial-object="true"
        >
          <template #graph="{ value }">
            <VBtn
              @click="() => loadGraph(value)"
              color="primary"
            >
              {{ idForGraph == value ? 'Hide graph' : 'Graph' }}
            </VBtn>
          </template>
        </FilterList>
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
import FilterComponent from './components/filter.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import { listParser } from './utils/listParser.js'
import { ANATOMICAL_PART } from '@/constants/index.js'
import { AnatomicalPart } from '@/routes/endpoints'
import { ATTRIBUTES } from './constants/attributes'
import { ref } from 'vue'
import floatGraph from './components/floatGraph.vue'
import RadialMatrix from '@/components/radials/matrix/radial.vue'

defineOptions({
  name: 'FilterAnatomicalParts'
})

const hideFrozen = ref(false)
const idForGraph = ref(null)

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
} = useFilter(AnatomicalPart, {
  listParser,
  sortableColumnsResource: 'anatomical_parts'
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
  objectType: ANATOMICAL_PART
})

function loadGraph(id) {
  idForGraph.value = idForGraph.value == id ? null : id
}
</script>
