<template>
  <div>
    <h1>Filter images</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="IMAGE"
      :list="list"
      :selected-ids="selectedIds"
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
            <DepictionList :image-id="selectedIds" />
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
          @on-sort="list = $event"
          @remove="({ index }) => list.splice(index, 1)"
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
import DepictionList from './components/DepictionList.vue'
import { IMAGE } from '@/constants/index.js'
import { Image } from '@/routes/endpoints'

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
} = useFilter(Image)
</script>

<script>
export default {
  name: 'FilterImages'
}
</script>
