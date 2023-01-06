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
      @filter="makeFilterRequest({ ...parameters, extend })"
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
                <TagAll
                  :ids="selectedIds"
                  type="Source"
                />
              </li>
              <li>
                <RadialFilter
                  :parameters="parameters"
                  object-type="Source"
                />
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
import RadialFilter from 'components/radials/filter/radial.vue'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import { Source } from 'routes/endpoints'
import { computed, reactive, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const extend = ['documents']

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

onBeforeMount(() => {
  parameters.value = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('filterQuery'))
  }

  sessionStorage.removeItem('filterQuery')

  if (Object.keys(parameters.value).length) {
    makeFilterRequest({
      ...parameters.value,
      extend
    })
  }
})

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
