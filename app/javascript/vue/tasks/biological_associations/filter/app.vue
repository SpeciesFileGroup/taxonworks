<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter biological associations</h1>
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
      :object-type="BIOLOGICAL_ASSOCIATION"
      :selected-ids="selectedIds"
      v-model:per="per"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <span class="separate-left separate-right">|</span>
        <CsvButton
          :list="csvFields"
          :options="{ fields }"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <ListComponent
            v-if="preferences.showList"
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
import ListComponent from './components/ListResults.vue'
import CsvButton from 'components/csvButton'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import VSpinner from 'components/spinner.vue'
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import { BIOLOGICAL_ASSOCIATION } from 'constants/index.js'
import { BiologicalAssociation } from 'routes/endpoints'
import { computed, reactive, ref } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

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

const fields = [
  'id',
  {
    label: 'Order',
    value: 'subject.taxonomy.order'
  },
  {
    label: 'Family',
    value: 'subject.taxonomy.family'
  },
  {
    label: 'Genus',
    value: (item) => item.subject.taxonomy.genus.filter(Boolean).join(' ')
  },
  {
    label: 'Subject',
    value: 'subject.object_label'
  },
  {
    label: 'Biological properties',
    value: (item) =>
      item.biological_relationship_types
        .filter((b) => b.target === 'subject')
        .map((b) => b.biological_property.name)
        .join(', ')
  },
  {
    label: 'Biological relationship',
    value: 'biological_relationship.object_label'
  },
  {
    label: 'Biological properties',
    value: (item) =>
      item.biological_relationship_types
        .filter((b) => b.target === 'object')
        .map((b) => b.biological_property.name)
        .join(', ')
  },
  {
    label: 'Order',
    value: 'object.taxonomy.order'
  },
  {
    label: 'Family',
    value: 'object.taxonomy.family'
  },
  {
    label: 'Genus',
    value: (item) => item.object.taxonomy.genus.filter(Boolean).join(' ')
  },
  {
    label: 'Object',
    value: 'object.object_label'
  }
]

const selectedIds = ref([])

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
} = useFilter(BiologicalAssociation)

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest({
    ...urlParams,
    geo_json: JSON.stringify(urlParams.geo_json),
    extend
  })
}
</script>

<script>
export default {
  name: 'FilterBiologicalAssociations'
}
</script>
