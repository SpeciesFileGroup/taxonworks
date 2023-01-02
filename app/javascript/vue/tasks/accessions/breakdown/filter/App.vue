<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter staged images</h1>
      <FilterSettings
        v-model:filter="preferences.activeFilter"
        v-model:url="preferences.activeJSONRequest"
        v-model:append="append"
        v-model:list="preferences.showList"
      />
    </div>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <FilterLayout
      :filter="preferences.activeFilter"
      :pagination="pagination"
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
      :logo-size="{ width: '100px', height: '100px'}"
    />
  </div>
</template>

<script setup>
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import VSpinner from 'components/spinner.vue'
import { CollectionObject } from 'routes/endpoints'
import { computed, reactive } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false
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

const sqedResult = computed(() => Array.isArray(list.value) ? {} : list.value)
const urlParams = URLParamsToJSON(location.href)

per.value = 50

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
