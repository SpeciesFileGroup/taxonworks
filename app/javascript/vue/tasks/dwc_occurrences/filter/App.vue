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
          :list="list"
          :attributes="ATTRIBUTES"
          :hide-unfrozen="hideFrozen"
          :preference-key="`tasks::filters::${DWC_OCCURRENCE}`"
          :radial-annotator="false"
          :radial-navigator="false"
          v-model="selectedIds"
          @on-sort="list = $event"
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <HideUnfrozenColumnsToggle v-model="hideFrozen" />
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
import useFilter from '@/shared/Filter/composition/useFilter.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import HideUnfrozenColumnsToggle from '@/components/Filter/Table/HideUnfrozenColumnsToggle.vue'
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
  resetFilter
} = useFilter(DwcOcurrence)
</script>

<script>
export default {
  name: 'FilterDwcOccurrence'
}
</script>
