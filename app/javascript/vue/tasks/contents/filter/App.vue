<template>
  <div class="margin-medium-top">
    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="CONTENT"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :radial-navigator="false"
      :extend-download="tsvDownload"
      only-extend-download
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
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
          :sortable-keys="sortableKeys"
          :attributes="ATTRIBUTES"
          :list="list"
          :preference-key="`tasks::filters::${CONTENT}`"
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
import { computed, ref } from 'vue'
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterView from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import TsvDownload from './components/TsvDownload.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import { listParser } from './utils/listParser'
import { ATTRIBUTES } from './constants/attributes'
import { Content } from '@/routes/endpoints'
import { CONTENT } from '@/constants/index.js'

const extend = ['otu', 'topic']
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
} = useFilter(Content, {
  listParser,
  initParameters: { extend },
  sortableColumnsResource: 'contents'
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
  objectType: CONTENT,
  extend
})

const tsvDownload = computed(() => [
  {
    label: 'TSV',
    component: TsvDownload,
    bind: {
      params: parameters.value,
      selectedList: selectedIds.value,
      pagination: pagination.value
    }
  }
])
</script>

<script>
export default {
  name: 'FilterContents'
}
</script>
