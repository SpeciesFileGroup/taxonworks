<template>
  <div>
    <VSpinner
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isLoading"
    />
    <div class="flex-separate middle">
      <h1>Filter sources</h1>
      <ul class="context-menu">
        <li>
          <a href="/tasks/sources/hub">Source hub</a>
        </li>
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
      </ul>
    </div>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <div class="horizontal-left-content align-start">
      <FilterComponent
        class="separate-right"
        v-show="preferences.activeFilter"
        @reset="resetFilter"
        @parameters="makeFilterRequest"
      />
      <div class="full_width">
        <div
          v-if="list.length"
          class="horizontal-left-content flex-separate separate-left separate-bottom"
        >
          <ul class="context-menu middle no_bullets">
            <li>
              <button
                type="button"
                class="button normal-input button-default"
                @click="selectedIds = selectedIds.length
                  ? []
                  : list.map(item => item.id)"
              >
                {{ selectedIds.length ? 'Unselect all ' :'Select all' }}
              </button>
            </li>
            <li>
              <CsvButton :list="csvList" />
            </li>
            <li>
              <BibliographyButton
                :selected-list="selectedIds"
                :pagination="pagination"
                :params="parameters"
              />
            </li>
            <li>
              <BibtexButton
                :selected-list="selectedIds"
                :pagination="pagination"
                :params="parameters"
              />
            </li>
          </ul>
        </div>
        <div
          class="flex-separate margin-medium-bottom"
          v-if="pagination"
        >
          <PaginationComponent
            :pagination="pagination"
            @next-page="loadPage"
          />
          <PaginationCount
            v-model="per"
            :pagination="pagination"
          />
        </div>
        <ListComponent
          v-model="selectedIds"
          :class="{ 'separate-left': preferences.activeFilter }"
          :list="list"
          @on-sort="list = $event"
        />
        <h2
          v-if="!list.length"
          class="subtle middle horizontal-center-content no-found-message"
        >
          No records found.
        </h2>
      </div>
    </div>
  </div>
</template>

<script setup>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from 'components/csvButton'
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount.vue'
import BibtexButton from './components/bibtex'
import BibliographyButton from './components/bibliography.vue'
import PlatformKey from 'helpers/getPlatformKey'
import VSpinner from 'components/spinner.vue'
import useFilter from 'tasks/people/filter/composables/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import { Source } from 'routes/endpoints'
import { computed, reactive, ref } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const selectedIds = ref([])
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
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter(Source)

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter(item => selectedIds.value.includes(item.id))
    : list.value
)

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest(urlParams)
}

TW.workbench.keyboard.createLegend(`${PlatformKey()}+f`, 'Search', 'Filter sources')
TW.workbench.keyboard.createLegend(`${PlatformKey()}+r`, 'Reset task', 'Filter sources')

</script>

<script>
export default {
  name: 'FilterSources'
}
</script>

<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>
