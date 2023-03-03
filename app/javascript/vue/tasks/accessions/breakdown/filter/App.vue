<template>
  <div>
    <h1>Filter staged images</h1>

    <FilterLayout
      :filter="preferences.activeFilter"
      :table="preferences.showList"
      :pagination="pagination"
      v-model="parameters"
      v-model:per="per"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <ListComponent
            v-if="Object.keys(sqedResult).length"
            :list="list"
            @on-sort="list = $event"
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
import { computed, reactive } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false,
  showList: true
})

const {
  isLoading,
  list,
  pagination,
  per,
  append,
  urlRequest,
  loadPage,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter({ filter: CollectionObject.sqedFilter })

const sqedResult = computed(() => (Array.isArray(list.value) ? {} : list.value))
const urlParams = URLParamsToJSON(location.href)

makeFilterRequest(urlParams)
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
