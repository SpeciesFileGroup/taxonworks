<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter collection objects</h1>
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
      :object-type="COLLECTION_OBJECT"
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
          <TagAll
            class="circle-button"
            :ids="selectedIds"
            :type="COLLECTION_OBJECT"
          />
          <DeleteCollectionObjects
            :ids="selectedIds"
            :disabled="!selectedIds.length"
            @delete="removeCOFromList"
          />
          <span class="separate-left separate-right">|</span>
          <LayoutConfiguration />
          <CsvButton
            class="margin-small-left"
            :list="coList?.data"
            :options="{ fields: csvFields }"
          />
          <DwcDownload
            class="margin-small-left"
            :params="parameters"
            :total="pagination?.total"
          />
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width overflow-x-scroll">
          <ListComponent
            v-if="coList.length"
            v-model="selectedIds"
            :list="coList"
            :layout="currentLayout"
            @on-sort="coList = $event"
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
import { computed, ref, reactive, onBeforeMount, watch } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse'
import { COLLECTION_OBJECT } from 'constants/index.js'
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from 'components/csvButton'
import DwcDownload from './components/dwcDownload.vue'
import TagAll from './components/tagAll'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import DeleteCollectionObjects from './components/DeleteCollectionObjects.vue'
import VSpinner from 'components/spinner.vue'
import LayoutConfiguration from './components/Layout/LayoutConfiguration.vue'
import { useLayoutConfiguration } from './components/Layout/useLayoutConfiguration'
import {
  COLLECTING_EVENT_PROPERTIES,
  COLLECTION_OBJECT_PROPERTIES,
  DWC_OCCURRENCE_PROPERTIES,
  REPOSITORY_PROPERTIES,
  TAXON_DETERMINATION_PROPERTIES
} from 'shared/Filter/constants'

const extend = [
  'dwc_occurrence',
  'repository',
  'current_repository',
  'data_attributes',
  'collecting_event',
  'taxon_determinations',
  'identifiers'
]

const defaultLayout = {
  properties: {
    collection_object: COLLECTION_OBJECT_PROPERTIES,
    current_repository: REPOSITORY_PROPERTIES,
    repository: REPOSITORY_PROPERTIES,
    collecting_event: COLLECTING_EVENT_PROPERTIES,
    taxon_determinations: TAXON_DETERMINATION_PROPERTIES,
    dwc_occurrence: DWC_OCCURRENCE_PROPERTIES,
    identifiers: ['cached']
  },
  includes: {
    data_attributes: true
  }
}

const { currentLayout } = useLayoutConfiguration(defaultLayout)

const selectedIds = ref([])
const coList = ref([])
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
} = useFilter(CollectionObject)

const csvFields = computed(() => {
  return list.value.map((item, index) => ({
    label: item,
    value: (row, field) => row[index] || field.default,
    default: ''
  }))
})

function removeCOFromList(ids) {
  list.value = list.value.filter((item) => !ids.includes(item.id))
  selectedIds.value = selectedIds.value.filter((id) => !ids.includes(id))
}

function parseDataAttributes(item) {
  const da = item.data_attributes

  if (!Array.isArray(da)) return

  const obj = {}

  da.forEach(({ predicate_name, value }) => {
    obj[predicate_name] = value
  })

  return obj
}

watch(list, (newVal) => {
  console.log('SE')
  coList.value = newVal.map((item) => {
    const baseAttributes = Object.assign(
      {},
      ...COLLECTION_OBJECT_PROPERTIES.map((property) => ({
        [property]: item[property]
      }))
    )

    return {
      ...item,
      collection_object: baseAttributes,
      data_attributes: parseDataAttributes(item)
    }
  })
})

onBeforeMount(() => {
  parameters.value = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('filterQuery'))
  }

  sessionStorage.removeItem('filterQuery')

  if (Object.keys(parameters.value).length) {
    makeFilterRequest({ ...parameters.value, extend })
  }
})
</script>

<script>
export default {
  name: 'FilterCollectionObjects'
}
</script>
