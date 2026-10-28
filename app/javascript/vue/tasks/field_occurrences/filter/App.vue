<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="FIELD_OCCURRENCE"
      :selected-ids="selectedIds"
      :list="list"
      :csv-options="csvOptions"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, page: 1 })"
      @per="makeFilterRequest({ ...parameters, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #nav-query-right>
        <RadialMatrix
          :parameters="parameters"
          :disabled="!list.length"
          :object-type="FIELD_OCCURRENCE"
        />
      </template>
      <template #nav-right>
        <RadialMatrix
          :ids="selectedIds"
          :disabled="!list.length"
          :object-type="FIELD_OCCURRENCE"
        />
        <DeleteFieldOccurrences
          :ids="selectedIds"
          :disabled="!selectedIds.length"
          @delete="removeFromList"
        />
        <span class="separate-left separate-right">|</span>
        <TableLayoutSelector
          v-model="currentLayout"
          v-model:includes="includes"
          v-model:properties="properties"
          :layouts="layouts"
          @reset="resetPreferences"
          @sort="updatePropertiesPositions"
          @sort:column="forceUpdatePreference"
          @update="saveLayoutPreferences"
        />
      </template>
      <template #table>
        <FilterList
          ref="filterListRef"
          :list="list"
          :layout="currentLayout"
          @reorder:layout="reorderLayoutColumns"
          :sortable-keys="sortableKeys"
          :max-sort-keys="maxSortKeys"
          :preference-key="`tasks::filters::${FIELD_OCCURRENCE}`"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          radial-object
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <SortPanel
          v-model:sort-keys="sortKeys"
          :labels="sortLabels"
          :sortable-keys="sortableKeys"
          :max-sort-keys="maxSortKeys"
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
import FilterView from './components/FilterView.vue'
import DeleteFieldOccurrences from './components/DeleteFieldOccurrences.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import { useFilter, useCSVOptions } from '@/shared/Filter/composition'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import TableLayoutSelector from '@/components/Filter/Table/TableLayoutSelector.vue'
import { LAYOUTS } from './constants/layouts'
import { listParser } from './utils/listParser'
import { FIELD_OCCURRENCE } from '@/constants/index.js'
import { FieldOccurrence } from '@/routes/endpoints'
import { useTableLayoutConfiguration } from '@/components/Filter/composables/useTableLayoutConfiguration.js'
import { computed, ref } from 'vue'
import { layoutSortLabels } from '@/shared/Filter/utils'

defineOptions({
  name: 'FilterFieldOccurrences'
})

const extend = [
  'collecting_event',
  'geographic_area_name',
  'taxon_determinations',
  'identifiers',
  'dwc_occurrence'
]
const exclude = ['object_labels']
const hideFrozen = ref(false)

const {
  currentLayout,
  includes,
  layouts,
  properties,
  updatePropertiesPositions,
  reorderLayoutColumns,
  saveLayoutPreferences,
  resetPreferences,
  forceUpdatePreference
} = useTableLayoutConfiguration({ layouts: LAYOUTS, model: FIELD_OCCURRENCE })

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
  sortableKeys,
  sortKeys,
  unsavedViewChanges,
  hasUnsavedChanges,
  filterListRef,
  saveViewAsDefault,
  maxSortKeys
} = useFilter(FieldOccurrence, {
  listParser,
  initParameters: { extend, exclude },
  sortableColumnsResource: 'field_occurrences',
  objectType: FIELD_OCCURRENCE
})

const sortLabels = computed(() =>
  layoutSortLabels(currentLayout.value?.properties)
)

const csvOptions = useCSVOptions({ layout: currentLayout, list })

function removeFromList(ids) {
  list.value = list.value.filter((item) => !ids.includes(item.id))
  selectedIds.value = selectedIds.value.filter((id) => !ids.includes(id))
}
</script>
