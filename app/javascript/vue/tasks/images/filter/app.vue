<template>
  <div class="margin-medium-top">
    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="IMAGE"
      :list="list"
      :selected-ids="sortedSelectedIds"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, page: 1 })"
      @per="makeFilterRequest({ ...parameters, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div
          v-if="list.length"
          class="horizontal-right-content"
        >
          <span class="margin-small-left margin-small-right">|</span>
          <div class="horizontal-left-content gap-small margin-small-left">
            <DepictionList :image-id="sortedSelectedIds" />
            <SelectAll
              v-model="selectedIds"
              :ids="list.map(({ id }) => id)"
            />
          </div>
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <ListComponent
          v-model="selectedIds"
          :list="list"
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <SortPanel
          v-model:sort-keys="sortKeys"
          :labels="SORT_LABELS"
          :sortable-keys="sortableKeys"
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
import ListComponent from './components/list'
import SelectAll from '@/tasks/collection_objects/filter/components/selectAll.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import DepictionList from './components/DepictionList.vue'
import { IMAGE } from '@/constants/index.js'
import { Image } from '@/routes/endpoints'

// Images render as a gallery (no column headers), so sort options are only
// reachable through the SortPanel picker. Keep the label map here.
const SORT_LABELS = {
  id: 'ID',
  user_file_name: 'User file name',
  image_file_file_name: 'File name',
  image_file_file_size: 'File size',
  image_file_content_type: 'Content type',
  height: 'Height',
  width: 'Width',
  updated_at: 'Updated at',
  created_at: 'Created at'
}

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
} = useFilter(Image, {
  sortableColumnsResource: 'images'
})

const {
  sortKeys,
  hasUnsavedChanges,
  saveViewAsDefault
} = useFilterView({
  parameters,
  makeFilterRequest,
  objectType: IMAGE
})
</script>

<script>
export default {
  name: 'FilterImages'
}
</script>
