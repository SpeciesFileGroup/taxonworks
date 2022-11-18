<template>
  <div>
    <spinner-component
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <div class="flex-separate middle">
      <h1>Collection object image breakdown (sqed) TODO list</h1>
      <menu-preferences v-model="preferences" />
    </div>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <div class="horizontal-left-content align-start">
      <filter-component
        class="margin-medium-right"
        v-show="preferences.activeFilter"
        @parameters="makeFilterRequest"
        @reset="resetFilter"
      />
      <div class="full_width overflow-x-auto">
        <div
          class="flex-separate margin-medium-bottom"
          v-if="pagination"
        >
          <pagination-component
            :pagination="pagination"
            @next-page="loadPage"
          />
          <pagination-count
            v-model="per"
            :pagination="pagination"
          />
        </div>

        <list-component
          v-if="Object.keys(sqedResult).length"
          :list="list"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount'
import MenuPreferences from './components/MenuPreferences.vue'
import SpinnerComponent from 'components/spinner.vue'
import useFilter from 'tasks/extracts/filter/composables/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
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
  urlRequest,
  loadPage,
  makeFilterRequest,
  resetFilter
} = useFilter({ filter: CollectionObject.sqedFilter })

const sqedResult = computed(() => Array.isArray(list.value) ? {} : list.value)

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest(urlParams)
}

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
