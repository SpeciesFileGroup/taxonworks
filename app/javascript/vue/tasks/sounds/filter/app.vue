<template>
  <div>
    <h1>Filter sounds</h1>

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
import ListResults from './components/ListResults.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import { SOUND } from '@/constants/index.js'
import { Sound } from '@/routes/endpoints'

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
  urlRequest
} = useFilter(Sound)
</script>

<script>
export default {
  name: 'FilterSounds'
}
</script>
