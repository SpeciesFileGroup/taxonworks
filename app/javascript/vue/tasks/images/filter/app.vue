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
      @filter="makeFilterRequest({ ...parameters })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div
          v-if="list.length"
          class="horizontal-right-content"
        >
          <span>|</span>
          <div class="margin-small-left">
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
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import SelectAll from 'tasks/collection_objects/filter/components/selectAll.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import { IMAGE } from 'constants/index.js'
import { Image } from 'routes/endpoints'

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
