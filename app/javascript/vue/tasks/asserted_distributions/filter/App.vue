<template>
  <div>
    <h1>Filter asserted distributions</h1>

    <FilterLayout
      :pagination="pagination"
      :selected-ids="sortedSelectedIds"
      :object-type="ASSERTED_DISTRIBUTION"
      :list="list"
      :url-request="urlRequest"
      v-model="parameters"
      v-model:append="append"
      @filter="() => {
        makeFilterRequest({ ...parameters, extend, page: 1 })
        resetMap()
      }"
      @per="() => {
        makeFilterRequest({ ...parameters, extend, page: 1 })
        resetMap()
      }"
      @nextpage="(event) => {
        loadPage(event)
        resetMap()
      }"
      @reset="() => {
        resetFilter()
        resetMap()
      }"
    >
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
          :ids="sortedSelectedIds"
          @update="() => makeFilterRequest({ ...parameters, extend, page: 1 })"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #above-table>
        <FloatMap
          v-if="idForMap"
          :geojson="geojson || [{}]"
          @close="() => resetMap()"
          show-close
        />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :attributes="ATTRIBUTES"
          :list="list"
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

          <template #map="{ value }">
            <VBtn
              @click="() => loadMap(value)"
              color="primary"
            >
              {{ idForMap == value ? 'Hide map' : 'Map' }}
            </VBtn>
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
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import RadialAssertedDistribution from '@/components/radials/asserted_distribution/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { AssertedDistribution } from '@/routes/endpoints'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'
import { ref } from 'vue'

const extend = ['citations', 'asserted_distribution_shape',
  'asserted_distribution_object'
]

defineOptions({
  name: 'FilterAssertedDistributions'
})

const idForMap = ref(null)
const geojson = ref(null)

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
} = useFilter(AssertedDistribution, { listParser, initParameters: { extend } })

function loadMap(id) {
  idForMap.value = idForMap.value == id ? null : id

  if (!idForMap.value) return

  AssertedDistribution.find(
      id, { extend: ['asserted_distribution_shape'], embed: ['shape']}
    )
    .then(({ body }) => {
      geojson.value = [body.asserted_distribution_shape.shape]
    })
    .catch(() => {})
}

function resetMap() {
  idForMap.value = null
  geojson.value = null
}

</script>
