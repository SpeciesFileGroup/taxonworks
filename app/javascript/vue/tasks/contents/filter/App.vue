<template>
  <div>
    <h1>Filter contents</h1>

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
      :selected-ids="selectedIds"
      :list="list"
      v-model:per="per"
      v-model:preferences="preferences"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div
          v-if="list.length"
          class="horizontal-right-content"
        >
          <TagAll
            class="circle-button"
            :ids="selectedIds"
            :type="CONTENT"
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
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
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
