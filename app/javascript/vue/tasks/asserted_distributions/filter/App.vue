<template>
  <div>
    <h1>Filter asserted distributions</h1>

    <FilterLayout
      :pagination="pagination"
      :selected-ids="selectedIds"
      :object-type="ASSERTED_DISTRIBUTION"
      :list="list"
      :url-request="urlRequest"
      v-model="parameters"
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
        <RadialAssertedDistribution
          :disabled="!list.length"
          :parameters="parameters"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #nav-right>
        <RadialAssertedDistribution
          :disabled="!list.length"
          :ids="selectedIds"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
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
          :attributes="ATTRIBUTES"
          :list="list"
          @mouseover:row="(row) => setRowHover(row)"
          @mouseout:body="() => (rowHover = null)"
          @on-sort="list = $event"
          @remove="({ index }) => list.splice(index, 1)"
        >
          <template #objectGlobalId="{ value, setHighlight }">
            <RadialObject
              v-if="value"
              :global-id="value"
              @click="setHighlight"
            />
          </template>
        </FilterList>
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
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterComponent from './components/FilterView.vue'
import FloatMap from '@/components/ui/map/FloatMap.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import RadialAssertedDistribution from '@/components/radials/asserted_distribution/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { AssertedDistribution } from '@/routes/endpoints'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'
import { computed, onBeforeMount, onMounted, reactive, ref } from 'vue'
import { sortArray } from '@/helpers/arrays'

const extend = ['citations', 'asserted_distribution_shape',
  'asserted_distribution_object'
]

const embed = ['shape']

defineOptions({
  name: 'FilterAssertedDistributions'
})

const rowHover = ref(null)
const isMouseDown = ref(false)

const preferences = reactive({
  showMap: false
})

const {
  isLoading,
  list,
  pagination,
  append,
  urlRequest,
  loadPage,
  parameters,
  selectedIds,
  makeFilterRequest,
  resetFilter
} = useFilter(AssertedDistribution, { listParser,
  initParameters: { extend, embed } })

const geojson = computed(() => {
  const hoverId = rowHover.value?.asserted_distribution?.id
  const hoverAssertedDistributions = list.value.filter(
    (item) => item.id === hoverId
  )
  const items = hoverAssertedDistributions.length
    ? hoverAssertedDistributions
    : list.value

  const geojsonObjects = items.map((assertedDistribution) => {
    const geojson = assertedDistribution.geojson

    geojson.properties.style = {
      fillOpacity: 0.2
    }
    // geojson['properties'].marker = {
    //   icon:
    //     assertedDistribution.id === hoverId ||
    //     selectedIds.value.includes(assertedDistribution.id)
    //       ? 'green'
    //       : 'blue'
    // }

    return geojson
  })

  return sortArray(geojsonObjects, 'properties.marker.icon')
})

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
