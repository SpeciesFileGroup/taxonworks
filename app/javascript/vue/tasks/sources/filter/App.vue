<template>
  <div>
    <h1>Filter sources</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="SOURCE"
      :selected-ids="selectedIds"
      :list="list"
      :extend-download="extendDownload"
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
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #nav-right>
        <RadialSource
          :disabled="!list.length"
          :ids="selectedIds"
          :count="selectedIds.length"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          :list="list"
          :attributes="ATTRIBUTES"
          v-model="selectedIds"
          radial-object
          @on-sort="list = $event"
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
            <td>
              <div class="flex-wrap-row gap-xsmall">
                <PdfButton
                  v-for="pdf in value"
                  :key="pdf.id"
                  :pdf="pdf"
                />
              </div>
            </td>
          </template>
        </FilterList>
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
import VSpinner from '@/components/spinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import FilterList from '@/components/Filter/Table/TableResults.vue'

import PdfButton from '@/components/pdfButton'
import AddToProject from '@/components/addToProjectSource'
import PinComponent from '@/components/ui/Pinboard/VPin.vue'

import { Source } from '@/routes/endpoints'
import { SOURCE } from '@/constants/index.js'
import { ATTRIBUTES } from './constants/attributes.js'
import { computed } from 'vue'

const extend = ['documents']

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
} = useFilter(Source, { initParameters: { extend } })

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

<script>
export default {
  name: 'FilterSources'
}
</script>
