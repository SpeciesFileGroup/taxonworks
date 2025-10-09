<template>
  <div>
    <h1>Filter collecting events</h1>

    <FilterLayout
      :pagination="pagination"
      v-model="parameters"
      :object-type="COLLECTING_EVENT"
      :selected-ids="sortedSelectedIds"
      :url-request="urlRequest"
      :list="list"
      :csv-options="csvOptions"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #preferences-last>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="preferences.showMap"
            />
            Show map
          </label>
        </li>
      </template>

      <template #nav-query-right>
        <RadialCollectingEvent
          :disabled="!list.length"
          :parameters="parameters"
          :count="pagination?.total || 0"
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
      </template>

      <template #nav-right>
        <div class="horizontal-right-content gap-small">
          <RadialCollectingEvent
            :disabled="!list.length"
            :ids="sortedSelectedIds"
            :count="sortedSelectedIds.length"
            @update="() => makeFilterRequest({ ...parameters, extend })"
          />
          <TableLayoutSelector
            v-model="currentLayout"
            v-model:includes="includes"
            v-model:properties="properties"
            :layouts="layouts"
            @reset="resetPreferences"
            @sort="updatePropertiesPositions"
            @sort:column="forceUpdatePreference"
            @update="saveLayoutPreferences"
          />
        </div>
      </template>

      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>

      <template #above-table>
        <FloatMap
          v-if="preferences.showMap"
          :geojson="geojson"
        />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :layout="currentLayout"
          :list="list"
          :radial-object="false"
          @mouseover:row="setRowHover"
          @mouseout:body="() => (rowHover = null)"
          @on-sort="($event) => (list = $event)"
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
    </FilterLayout>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
  </div>
</template>

<script setup>
import FilterComponent from './components/Filter.vue'
import FloatMap from '@/components/ui/map/FloatMap.vue'
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { useFilter, useCSVOptions } from '@/shared/Filter/composition'
import RadialCollectingEvent from '@/components/radials/ce/radial.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import TableLayoutSelector from '@/components/Filter/Table/TableLayoutSelector.vue'
import { listParser } from './utils/listParser.js'
import { COLLECTING_EVENT } from '@/constants/index.js'
import { computed, ref, reactive, onMounted, onBeforeMount } from 'vue'
import { sortArray } from '@/helpers/arrays'
import { CollectingEvent } from '@/routes/endpoints'
import { LAYOUTS } from './constants/layouts.js'
import { useTableLayoutConfiguration } from '@/components/Filter/composables/useTableLayoutConfiguration.js'

defineOptions({
  name: 'FilterCollectingEvent'
})

const extend = ['roles']

const {
  currentLayout,
  includes,
  layouts,
  properties,
  updatePropertiesPositions,
  saveLayoutPreferences,
  resetPreferences,
  forceUpdatePreference
} = useTableLayoutConfiguration({ layouts: LAYOUTS, model: COLLECTING_EVENT })

const geojson = computed(() => {
  const hoverId = rowHover.value?.collecting_event?.id
  const hoverGeoreferences = georeferences.value.filter(
    (item) => item.collecting_event_id === hoverId
  )
  const items = hoverGeoreferences.length
    ? hoverGeoreferences
    : georeferences.value

  const geojsonObjects = items.map((georeference) => {
    const geojson = georeference.geo_json

    geojson.properties.marker = {
      icon:
        georeference.collecting_event_id === hoverId ||
        selectedIds.value.includes(georeference.collecting_event_id)
          ? 'green'
          : 'blue'
    }

    return geojson
  })

  return sortArray(geojsonObjects, 'properties.marker.icon')
})

const preferences = reactive({
  showMap: false
})

const {
  append,
  isLoading,
  list,
  loadPage,
  makeFilterRequest,
  pagination,
  parameters,
  resetFilter,
  selectedIds,
  sortedSelectedIds,
  urlRequest
} = useFilter(CollectingEvent, {
  listParser,
  initParameters: { extend }
})

const csvOptions = useCSVOptions({ layout: currentLayout, list })
const isMouseDown = ref(false)
const rowHover = ref()
const georeferences = computed(() =>
  list.value.map((item) => item.georeferences).flat()
)

const setRowHover = ({ item }) => {
  if (!isMouseDown.value) {
    rowHover.value = item
  }
}

function onMouseDown() {
  isMouseDown.value = true
}

function onMouseUp() {
  isMouseDown.value = false
}

onMounted(() => {
  document.addEventListener('mousedown', onMouseDown)
  document.addEventListener('mouseup', onMouseUp)
})

onBeforeMount(() => {
  document.removeEventListener('mousedown', onMouseDown)
  document.removeEventListener('mouseup', onMouseUp)
})
</script>
