<template>
  <div>
    <h1>Filter collection objects</h1>

    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :selected-ids="selectedIds"
      :object-type="COLLECTION_OBJECT"
      :list="list"
      :extend-download="extendDownload"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div class="horizontal-right-content">
          <DeleteCollectionObjects
            :ids="selectedIds"
            :disabled="!selectedIds.length"
            @delete="removeCOFromList"
          />
          <span class="separate-left separate-right">|</span>

          <LayoutConfiguration />
        </div>
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <ListComponent
          v-model="selectedIds"
          :list="coList"
          :layout="currentLayout"
          @on-sort="coList = $event"
        />
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
import useFilter from 'shared/Filter/composition/useFilter.js'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import DwcDownload from './components/dwcDownload.vue'
import DeleteCollectionObjects from './components/DeleteCollectionObjects.vue'
import VSpinner from 'components/spinner.vue'
import LayoutConfiguration from './components/Layout/LayoutConfiguration.vue'
import { computed, ref, watch } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import { COLLECTION_OBJECT } from 'constants/index.js'
import { useLayoutConfiguration } from './components/Layout/useLayoutConfiguration'
import { LAYOUTS } from './constants/layouts.js'
import { COLLECTION_OBJECT_PROPERTIES } from 'shared/Filter/constants'

const extend = [
  'dwc_occurrence',
  'repository',
  'current_repository',
  'data_attributes',
  'collecting_event',
  'taxon_determinations',
  'identifiers'
]

const { currentLayout } = useLayoutConfiguration(LAYOUTS)

const selectedIds = ref([])
const coList = ref([])

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
} = useFilter(CollectionObject, { initParameters: { extend } })

const extendDownload = computed(() => [
  {
    label: 'DwC',
    component: DwcDownload,
    bind: {
      params: parameters.value,
      total: pagination.value?.total
    }
  }
])

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
</script>

<script>
export default {
  name: 'FilterCollectionObjects'
}
</script>
