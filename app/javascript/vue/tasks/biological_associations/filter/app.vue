<template>
  <div>
    <h1>Filter biological associations</h1>

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
      :object-type="BIOLOGICAL_ASSOCIATION"
      :selected-ids="selectedIds"
      :list="list"
      v-model:preferences="preferences"
      v-model:append="append"
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
        <div class="full_width overflow-x-auto">
          <FilterList
            v-if="preferences.showList"
            v-model="selectedIds"
            :attributes="ATTRIBUTES"
            :header-groups="HEADERS"
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
import CsvButton from 'components/csvButton'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import VSpinner from 'components/spinner.vue'
import FilterList from 'components/layout/Filter/FilterList.vue'
import { listParser } from './utils/listParser'
import { BIOLOGICAL_ASSOCIATION } from 'constants/index.js'
import { BiologicalAssociation } from 'routes/endpoints'
import { computed, reactive, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const ATTRIBUTES = {
  subject_taxonomy_order: 'Order',
  subject_taxonomy_family: 'Family',
  subject_taxonomy_genus: 'Genus',
  subject_object_tag: 'Object tag',
  biological_property_subject: 'Biological properties',
  biological_relationship: 'Biological relationship',
  biological_property_object: 'Biological properties',
  object_taxonomy_order: 'Order',
  object_taxonomy_family: 'Family',
  object_taxonomy_genus: 'Genus',
  object_object_tag: 'Object tag'
}

const HEADERS = [
  {
    colspan: 2
  },
  {
    title: 'Subject',
    colspan: 5,
    scope: 'colgroup'
  },
  {
    colspan: 1
  },
  {
    title: 'Object',
    colspan: 5,
    scope: 'colgroup'
  }
]

const extend = [
  'object',
  'subject',
  'biological_relationship',
  'taxonomy',
  'biological_relationship_types'
]

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false,
  showList: true
})

const csvFields = computed(() => (selectedIds.value.length ? list.value : []))
const selectedIds = ref([])

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
} = useFilter(BiologicalAssociation, { listParser })

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
  name: 'FilterBiologicalAssociations'
}
</script>
