<template>
  <div>
    <h1>Filter OTUs</h1>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <FilterLayout
      :filter="preferences.activeFilter"
      :table="preferences.showList"
      :pagination="pagination"
      :parameters="parameters"
      :object-type="OTU"
      v-model:per="per"
      v-model:preferences="preferences"
      v-model:append="append"
      :selected-ids="selectedIds"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="csvFields" />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <ListComponent
            v-model="selectedIds"
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
import FilterComponent from './components/FilterView.vue'
import ListComponent from './components/list'
import CsvButton from 'components/csvButton'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import VSpinner from 'components/spinner.vue'
import { OTU } from 'constants/index.js'
import { Otu } from 'routes/endpoints'
import { computed, reactive, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const extend = ['taxonomy']

const csvFields = computed(() => (selectedIds.value.length ? list.value : []))

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
} = useFilter(Otu)

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
