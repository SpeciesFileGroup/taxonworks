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
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
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
          :sortable-keys="sortableKeys"
          :preference-key="`tasks::filters::${FIELD_OCCURRENCE}`"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
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
import FilterView from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import { useFilter, useCSVOptions } from '@/shared/Filter/composition'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import { humanize } from '@/helpers/strings.js'
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

defineOptions({
  name: 'FilterFieldOccurrences'
})

const extend = [
  'collecting_event',
  'taxon_determinations',
  'identifiers',
  'dwc_occurrence'
]
const hideFrozen = ref(false)

const {
  currentLayout,
  includes,
  layouts,
  properties,
  updatePropertiesPositions,
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
  sortableKeys
} = useFilter(FieldOccurrence, {
  listParser,
  initParameters: { extend },
  sortableColumnsResource: 'field_occurrences'
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
  objectType: FIELD_OCCURRENCE,
  extend
})

const sortLabels = computed(() => {
  const map = {}
  const properties = currentLayout.value?.properties || {}
  for (const [group, cols] of Object.entries(properties)) {
    if (Array.isArray(cols)) {
      const groupLabel = humanize(group)
      for (const col of cols) {
        map[`${group}.${col}`] = `${groupLabel} · ${col}`
      }
    }
  }
  return map
})

const csvOptions = useCSVOptions({ layout: currentLayout, list })
</script>
