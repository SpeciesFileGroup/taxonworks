<template>
  <div>
    <h1>Filter nomenclature</h1>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <FilterLayout
      :filter="preferences.activeFilter"
      :table="preferences.showList"
      :pagination="pagination"
      v-model="parameters"
      :selected-ids="selectedIds"
      :object-type="TAXON_NAME"
      :list="list"
      v-model:preferences="preferences"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <RadialLabel
          :object-type="TAXON_NAME"
          :ids="selectedIds"
          :disabled="!selectedIds.length"
        />
        <span class="separate-left separate-right">|</span>
        <CsvButton
          :list="csvList"
          :options="{ fields }"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <FilterList
            v-model="selectedIds"
            :attributes="ATTRIBUTES"
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
import FilterList from 'components/layout/Filter/FilterList.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import RadialLabel from 'components/radials/label/radial.vue'
import { ATTRIBUTES } from './constants/attributes.js'
import { listParser } from './utils/listParser'
import { TaxonName } from 'routes/endpoints'
import { reactive, ref, computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import { TAXON_NAME } from 'constants/index.js'

const extend = ['parent']

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
} = useFilter(TaxonName, { listParser })

const selectedIds = ref([])

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)

onBeforeMount(() => {
  const urlParameters = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('filterQuery'))
  }

  Object.assign(parameters.value, urlParameters)

  sessionStorage.removeItem('filterQuery')

  if (Object.keys(urlParameters).length) {
    makeFilterRequest({
      ...parameters.value,
      extend
    })
  }
})
</script>

<script>
export default {
  name: 'FilterNomenclature'
}
</script>
