<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter nomenclature</h1>
      <FilterSettings
        v-model:filter="preferences.activeFilter"
        v-model:url="preferences.activeJSONRequest"
        v-model:append="append"
        v-model:list="preferences.showList"
      />
    </div>

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
      :selected-ids="selectedIds"
      :object-type="TAXON_NAME"
      v-model:per="per"
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
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import RadialLabel from 'components/radials/label/radial.vue'
import ModalNestedParameters from 'components/Filter/ModalNestedParameters.vue'
import { TaxonName } from 'routes/endpoints'
import { reactive, ref, computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import qs from 'qs'
import { TAXON_NAME } from 'constants/index.js'

const fields = [
  'id',
  { label: 'name', value: 'cached' },
  { label: 'author', value: 'cached_author_year' },
  { label: 'year of publication', value: 'year_of_publication' },
  { label: 'original combination', value: 'cached_original_combination' },
  'rank',
  { label: 'parent', value: 'parent.cached' }
]

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
  per,
  append,
  urlRequest,
  loadPage,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter(TaxonName)

const selectedIds = ref([])

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)

onBeforeMount(() => {
  console.log(URLParamsToJSON(location.href))
  parameters.value = {
    ...qs.stringify(location.search, { arrayFormat: 'brackets' }),
    ...URLParamsToJSON(location.href)
    //...JSON.parse(sessionStorage.getItem('filterQuery'))
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
  name: 'FilterNomenclature'
}
</script>
