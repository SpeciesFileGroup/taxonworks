<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter extracts</h1>
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
      :pagination="pagination"
      v-model:per="per"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <ul
          v-if="list.length"
          class="context-menu no_bullets horizontal-right-content"
        >
          <li>
            <RadialLabel
              :object-type="TAXON_NAME"
              :ids="selectedIds"
              :disabled="!selectedIds.length"
            />
          </li>
          <li>
            <CsvButton :list="csvList" />
          </li>
        </ul>
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
      :logo-size="{ width: '100px', height: '100px'}"
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
import { TaxonName } from 'routes/endpoints'
import { reactive, ref, computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import { TAXON_NAME } from 'constants/index.js'

const extend = ['parent']

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false
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
    ? list.value.filter(item => selectedIds.value.includes(item.id))
    : list.value
)

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest({ ...urlParams, extend })
}

</script>

<script>
export default {
  name: 'FilterNomenclature'
}
</script>
