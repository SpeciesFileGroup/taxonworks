<template>
  <div>
    <h1>Filter loans</h1>

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
      :selected-ids="selectedIds"
      :object-type="LOAN"
      v-model:per="per"
      v-model:preferences="preferences"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <TagAll
          :ids="selectedIds"
          :type="LOAN"
        />
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="csvList" />
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
import { Loan } from 'routes/endpoints'
import { LOAN } from 'constants/index.js'
import { computed, reactive, ref, onBeforeMount } from 'vue'
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
} = useFilter(Loan)

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
      ...parameters.value
    })
  }
})
</script>

<script>
export default {
  name: 'FilterLoans'
}
</script>
