<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter sources</h1>
      <FilterSettings
        v-model:filter="preferences.activeFilter"
        v-model:url="preferences.activeJSONRequest"
        v-model:append="append"
        v-model:list="preferences.showList"
      >
        <template #first>
          <li>
            <a href="/tasks/sources/hub">Source hub</a>
          </li>
        </template>
      </FilterSettings>
    </div>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <FilterLayout
      :filter="preferences.activeFilter"
      :pagination="pagination"
      :table="preferences.showList"
      v-model:per="per"
      @filter="makeFilterRequest({ ...parameters, extend: ['documents'] })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div
          v-if="list.length"
          class="horizontal-right-content"
        >
          <div class="horizontal-left-content">
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
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <ListComponent
            v-model="selectedIds"
            :class="{ 'separate-left': preferences.activeFilter }"
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
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from 'components/csvButton'
import BibtexButton from './components/bibtex'
import BibliographyButton from './components/bibliography.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'

import { Source } from 'routes/endpoints'
import { computed, reactive, ref } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const selectedIds = ref([])
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
} = useFilter(Source)

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter(item => selectedIds.value.includes(item.id))
    : list.value
)

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest({ ...urlParams, extend: ['documents'] })
}

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
