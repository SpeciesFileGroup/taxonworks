<template>
  <div>
    <h1>Filter people</h1>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <FilterLayout
      :filter="preferences.activeFilter"
      :list="list"
      :object-type="PEOPLE"
      :pagination="pagination"
      v-model="parameters"
      :selected-ids="selectedIds"
      :table="preferences.showList"
      v-model:preferences="preferences"
      v-model:append="append"
      @filter="makeFilterRequest()"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <span class="separate-left separate-right">|</span>
        <CsvButton
          class="margin-small-left"
          :list="csvList"
        />
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
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import { PEOPLE } from 'constants/index.js'
import { People } from 'routes/endpoints'
import { computed, reactive, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)

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
  append,
  urlRequest,
  loadPage,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter(People)

onBeforeMount(() => {
  const urlParameters = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('filterQuery'))
  }

  Object.assign(parameters.value, urlParameters)

  sessionStorage.removeItem('filterQuery')

  if (Object.keys(urlParameters).length) {
    makeFilterRequest({ ...parameters.value })
  }
})
</script>

<script>
export default {
  name: 'FilterPeople'
}
</script>
