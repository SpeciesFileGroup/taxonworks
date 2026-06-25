<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :radial-filter="false"
      :radial-linker="false"
      :radial-mass-annotator="false"
      :radial-navigator="false"
      :button-unify="false"
      v-model="parameters"
      v-model:append="append"
      @filter="handleFilter"
      @per="handleFilter"
      @nextpage="loadPage"
      @reset="handleReset"
    >
      <template #facets>
        <FilterView
          v-model="parameters"
          :annotation-type="annotationType"
          @annotation-type-change="onAnnotationTypeChange"
        />
      </template>
      <template #table>
        <FilterList
          v-if="annotationType"
          :list="list"
          :attributes="currentAttributes"
          :hide-unfrozen="hideFrozen"
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
import VSpinner from '@/components/ui/VSpinner.vue'
import HideUnfrozenColumnsToggle from '@/components/Filter/Table/HideUnfrozenColumnsToggle.vue'
import useAnnotationFilter from './composables/useAnnotationFilter.js'
import { ref } from 'vue'

defineOptions({
  name: 'FilterAnnotations'
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
  annotationType,
  currentAttributes,
  setAnnotationType
} = useAnnotationFilter()

function handleFilter() {
  if (!annotationType.value) return

  makeFilterRequest({
    ...parameters.value,
    annotation_type: annotationType.value,
    extend: ['annotated_object'],
    page: 1
  })
}

function handleReset() {
  setAnnotationType(null)
  resetFilter()
}

function onAnnotationTypeChange(typeKey) {
  setAnnotationType(typeKey)
  parameters.value = { per: parameters.value.per }
}
</script>
