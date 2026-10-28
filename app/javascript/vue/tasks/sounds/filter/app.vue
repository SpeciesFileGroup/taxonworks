<template>
  <div class="margin-medium-top">
    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="SOUND"
      :list="list"
      :selected-ids="sortedSelectedIds"
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
          :object-type="SOUND"
        />
      </template>
      <template #nav-right>
        <RadialMatrix
          :ids="sortedSelectedIds"
          :disabled="!list.length"
          :object-type="SOUND"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <ListResults
          v-model="selectedIds"
          :list="list"
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
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import { SOUND } from '@/constants/index.js'
import { Sound } from '@/routes/endpoints'
import { sortKeyLabels } from '@/shared/Filter/utils'
import { computed } from 'vue'

// Sounds uses a custom audio-player list, not TableResults, so sort options
// are only reachable through the SortPanel picker.
const SORT_LABEL_OVERRIDES = { id: 'ID' }

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
  sortableKeys,
  sortKeys,
  hasUnsavedChanges,
  saveViewAsDefault,
  maxSortKeys
} = useFilter(Sound, {
  sortableColumnsResource: 'sounds',
  objectType: SOUND
})

const sortLabels = computed(() =>
  sortKeyLabels(sortableKeys.value || [], SORT_LABEL_OVERRIDES)
)
</script>

<script>
export default {
  name: 'FilterSounds'
}
</script>
