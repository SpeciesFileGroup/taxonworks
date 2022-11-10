<template>
  <div>
    <spinner-component
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <div class="flex-separate middle">
      <h1>Filter nomenclature</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="preferences.activeFilter"
            >
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="preferences.activeJSONRequest"
            >
            Show JSON Request
          </label>
        </li>
        <li>
          <RadialLabel
            :object-type="TAXON_NAME"
            :ids="selectedIds"
            :disabled="!selectedIds.length"
          />
        </li>
        <li>
          <CsvComponent :list="list" />
        </li>
      </ul>
    </div>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <div class="horizontal-left-content align-start">
      <FilterComponent
        v-show="preferences.activeFilter"
        @parameters="makeFilterRequest"
        @reset="resetFilter"
      />
      <div class="full_width">
        <div
          class="flex-separate margin-medium-bottom"
          :class="{ 'separate-left': preferences.activeFilter }"
        >
          <template v-if="pagination && list.length">
            <PaginationComponent
              :pagination="pagination"
              @next-page="loadPage"
            />
            <PaginationCount
              :pagination="pagination"
              v-model="per"
            />
          </template>
        </div>
        <ListComponent
          :class="{ 'margin-medium-left': preferences.activeFilter }"
          :list="list"
          v-model="selectedIds"
          @on-sort="list = $event"
        />
        <h3
          v-if="!list.length"
          class="subtle middle horizontal-center-content"
        >
          No records found.
        </h3>
      </div>
    </div>
  </div>
</template>

<script setup>
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvComponent from './components/convertCsv.vue'
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount'
import SpinnerComponent from 'components/spinner.vue'
import useFilter from 'tasks/people/filter/composables/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import RadialLabel from 'components/radials/label/radial.vue'
import { TaxonName } from 'routes/endpoints'
import { reactive, ref } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import { TAXON_NAME } from 'constants/index.js'

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
} = useFilter(TaxonName)

const selectedIds = ref([])

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest(urlParams)
}

</script>

<script>
export default {
  name: 'FilterNomenclature'
}
</script>

<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>
