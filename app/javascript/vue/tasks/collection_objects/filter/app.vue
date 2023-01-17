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
      :object-type="COLLECTION_OBJECT"
      v-model:per="per"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div
          v-if="Object.keys(coList).length"
          class="horizontal-right-content"
        >
          <RadialLinker
            :parameters="parameters"
            object-type="CollectionObject"
          />
          <TagAll
            class="circle-button"
            :ids="selectedIds"
            type="CollectionObject"
          />
          <DeleteCollectionObjects
            :ids="selectedIds"
            :disabled="!selectedIds.length"
            @delete="removeCOFromList"
          />
          <span class="separate-left separate-right">|</span>
          <CsvButton
            :list="coList?.data"
            :options="{ fields: csvFields }"
          />
          <dwc-download
            class="margin-small-left"
            :params="parameters"
            :total="pagination?.total"
          />
          <dwc-reindex
            class="margin-small-left"
            :params="parameters"
            :total="pagination?.total"
          />
          <match-button
            :ids="selectedIds"
            :url="urlRequest"
            class="margin-small-left"
          />
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <ListComponent
            v-if="coList?.data?.length"
            v-model="selectedIds"
            :list="coList"
            @on-sort="coList.data = $event"
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
import { computed, ref, reactive, watch, onBeforeMount } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse'
import { chunkArray } from 'helpers/arrays'
import { COLLECTION_OBJECT } from 'constants/index.js'
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from 'components/csvButton'
import DwcDownload from './components/dwcDownload.vue'
import DwcReindex from './components/dwcReindex.vue'
import TagAll from './components/tagAll'
import MatchButton from './components/matchButton.vue'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import DeleteCollectionObjects from './components/DeleteCollectionObjects.vue'
import RadialLinker from 'components/radials/linker/radial.vue'
import VSpinner from 'components/spinner.vue'

const selectedIds = ref([])
const coList = ref({})
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

const PER_REQUEST = 10

const dwcaCount = ref(0)

const csvFields = computed(() => {
  if (!Object.keys(coList.value).length) return []

  return coList.value.column_headers.map((item, index) => ({
    label: item,
    value: (row, field) => row[index] || field.default,
    default: ''
  }))
})

function removeCOFromList (ids) {
  coList.value.data = coList.value.data.filter(r => !ids.includes(r[0]))
  selectedIds.value = selectedIds.value.filter(id => !ids.includes(id))
}

function getDWCATable (list) {
  const IDs = chunkArray(list.map(item => item[0]), PER_REQUEST)

  getDWCA(IDs)
}

function isIndexed (object) {
  return object.find((item, index) => item != null && index > 0)
}

function getDWCA (ids) {
  if (ids.length) {
    const failedRequestIds = []
    const idArray = ids.shift(0)
    const promises = idArray.map(id => CollectionObject.dwc(id).then(response => {
      const index = coList.value.data.findIndex(item => item[0] === id)

      dwcaCount.value++
      coList.value.data[index] = response.body
    }, _ => {
      failedRequestIds.push(id)
    }))

    isLoading.value = true

    Promise.allSettled(promises).then(_ => {
      if (failedRequestIds.length) {
        ids.push(failedRequestIds)
      }

      getDWCA(ids)
    })
  } else {
    dwcaCount.value = 0
    isLoading.value = false
  }
}

watch(
  list,
  newVal => {
    if (newVal?.data?.length) {
      const dwcaSearch = newVal.data.filter(item => !isIndexed(item))

      coList.value = { ...newVal }

      if (dwcaSearch.length) {
        getDWCATable(dwcaSearch)
      }
    } else {
      coList.value = {}
    }
  }
)

onBeforeMount(() => {
  parameters.value = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('filterQuery'))
  }

  sessionStorage.removeItem('filterQuery')

  if (Object.keys(parameters.value).length) {
    makeFilterRequest({ ...parameters.value })
  }
})
</script>

<script>
export default {
  name: 'FilterCollectionObjects'
}
</script>
