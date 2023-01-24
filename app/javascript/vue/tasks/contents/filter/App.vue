<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter contents</h1>
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
      :parameters="parameters"
      :object-type="CONTENT"
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
          <RadialFilter
            :ids="selectedIds"
            :disabled="!selectedIds.length"
            :object-type="CONTENT"
          />
          <RadialLinker
            :ids="selectedIds"
            :disabled="!selectedIds.length"
            :object-type="CONTENT"
          />
          <TagAll
            class="circle-button"
            :ids="selectedIds"
            type="Source"
          />
          <span class="separate-left separate-right">|</span>
          <CsvButton :list="csvList" />
        </div>
      </template>
      <template #facets>
        <FilterView v-model="parameters" />
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
      :logo-size="{ width: '100px', height: '100px' }"
    />
  </div>
</template>

<script setup>
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import FilterView from './components/FilterView.vue'
import ListComponent from './components/ListComponent.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import RadialLinker from 'components/radials/linker/radial.vue'
import RadialFilter from 'components/radials/filter/radial.vue'
import { Content } from 'routes/endpoints'
import { CONTENT } from 'constants/index.js'
import { computed, reactive, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const extend = ['otu', 'topic']

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
} = useFilter(Content)

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
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
  name: 'FilterContents'
}
</script>
