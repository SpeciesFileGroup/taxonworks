<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="SOURCE"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :extend-download="extendDownload"
      :csv-options="csvOptions"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialSource
          :disabled="!list.length"
          :parameters="parameters"
          :count="pagination?.total || 0"
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
      </template>
      <template #nav-right>
        <RadialSource
          :disabled="!list.length"
          :ids="sortedSelectedIds"
          :count="sortedSelectedIds.length"
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          ref="filterListRef"
          :list="list"
          :attributes="ATTRIBUTES"
          :sortable-keys="sortableKeys"
          :preference-key="`tasks::filters::${SOURCE}`"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
          radial-object
          @remove="({ index }) => list.splice(index, 1)"
        >
          <template #buttons-left="{ item }">
            <AddToProject
              :id="item.id"
              :project-source-id="item.project_source_id"
            />
            <PinComponent
              class="button button-circle"
              :object-id="item.id"
              :type="SOURCE"
            />
          </template>
          <template #documents="{ value }">
            <div class="flex-wrap-row gap-xsmall">
              <PdfButton
                v-for="pdf in value"
                :key="pdf.id"
                :pdf="pdf"
              />
            </div>
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
import BibtexButton from './components/bibtex'
import BibliographyDownload from './components/BibliographyDownload.vue'
import RadialSource from '@/components/radials/source/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'

import PdfButton from '@/components/ui/Button/ButtonPdf'
import AddToProject from '@/components/ui/Button/ButtonAddToProjectSource'
import PinComponent from '@/components/ui/Button/ButtonPin.vue'

import { Source } from '@/routes/endpoints'
import { SOURCE } from '@/constants/index.js'
import { ATTRIBUTES } from './constants/attributes.js'
import { computed, ref } from 'vue'

const extend = ['documents', 'serial']
const hideFrozen = ref(false)

defineOptions({
  name: 'FilterSources'
})

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
} = useFilter(Source, {
  initParameters: { extend },
  sortableColumnsResource: 'sources'
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
  objectType: SOURCE,
  extend
})

const csvOptions = {
  fields: [
    'id',
    {
      label: 'serial',
      value: 'serial_name'
    },
    'author',
    'year',
    'title',
    'volume',
    'number',
    'cached'
  ]
}

const extendDownload = computed(() => [
  {
    label: 'BibTeX',
    component: BibtexButton,
    bind: {
      selectedList: selectedIds.value,
      pagination: pagination.value,
      params: parameters.value
    }
  },
  {
    label: 'Download formatted',
    component: BibliographyDownload,
    bind: {
      selectedList: selectedIds.value,
      pagination: pagination.value,
      params: parameters.value
    }
  }
])
</script>
