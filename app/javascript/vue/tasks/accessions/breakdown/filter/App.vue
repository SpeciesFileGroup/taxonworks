<template>
  <div>
    <h1>Filter staged images</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <ListComponent
            v-if="!Array.isArray(list.value)"
            :list="list"
          />
        </div>
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
import useFilter from 'shared/Filter/composition/useFilter.js'
import VSpinner from 'components/spinner.vue'
import { CollectionObject } from 'routes/endpoints'
import { onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const {
  isLoading,
  list,
  pagination,
  urlRequest,
  loadPage,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter({ filter: CollectionObject.sqedFilter })

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  if (!Object.keys(urlParams).length) {
    makeFilterRequest()
  }
})
</script>

<script>
export default {
  name: 'BreakdownSqed'
}
</script>

<style scoped>
.no-found-message {
  height: 70vh;
}
</style>
