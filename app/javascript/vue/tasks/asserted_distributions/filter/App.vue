<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :selected-ids="sortedSelectedIds"
      :object-type="ASSERTED_DISTRIBUTION"
      :list="list"
      :url-request="urlRequest"
      v-model="parameters"
      v-model:append="append"
      @filter="
        () => {
          makeFilterRequest({ ...parameters, extend, page: 1 })
          resetMap()
        }
      "
      @per="
        () => {
          makeFilterRequest({ ...parameters, extend, page: 1 })
          resetMap()
        }
      "
      @nextpage="
        (event) => {
          loadPage(event)
          resetMap()
        }
      "
      @reset="
        () => {
          resetFilter()
          resetMap()
        }
      "
    >
      <template #nav-query-right>
        <RadialAssertedDistribution
          :disabled="!list.length"
          :parameters="parameters"
          @update="() => makeFilterRequest({ ...parameters, extend })"
        />
      </template>
      <template #nav-right>
        <RadialAssertedDistribution
          :disabled="!list.length"
          :ids="sortedSelectedIds"
          @update="() => makeFilterRequest({ ...parameters, extend })"
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
          ref="filterListRef"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:hide-unfrozen="hideFrozen"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
          :sortable-keys="sortableKeys"
          :attributes="ATTRIBUTES"
          :list="list"
          :preference-key="`tasks::filters::${ASSERTED_DISTRIBUTION}`"
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
      <template #nav-settings-start>
        <SortPanel
          v-model:sort-keys="sortKeys"
          :labels="ATTRIBUTES"
          :sortable-keys="sortableKeys"
        />
        <SaveViewButton
          v-if="hasUnsavedChanges"
          @save="saveViewAsDefault"
        />
        <VToggle
          v-model="hideFrozen"
          title="Hide non-frozen columns"
        >
          <VIcon
            :name="hideFrozen ? 'contract' : 'expand'"
            x-small
          />
        </VToggle>
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
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import useFilterView from '@/shared/Filter/composition/useFilterView.js'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import RadialAssertedDistribution from '@/components/radials/asserted_distribution/radial.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { AssertedDistribution } from '@/routes/endpoints'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'
import { ref } from 'vue'

const extend = [
  'citations',
  'asserted_distribution_shape',
  'asserted_distribution_object'
]

defineOptions({
  name: 'FilterAssertedDistributions'
})

const hideFrozen = ref(false)
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
  urlRequest,
  sortableKeys
} = useFilter(AssertedDistribution, {
  listParser,
  initParameters: { extend },
  sortableColumnsResource: 'asserted_distributions'
})

const {
  sortKeys,
  unsavedViewChanges,
  hasUnsavedChanges,
  filterListRef,
  saveViewAsDefault
} = useFilterView({
  parameters,
  makeFilterRequest,
  objectType: ASSERTED_DISTRIBUTION,
  extend
})

function loadMap(id) {
  idForMap.value = idForMap.value == id ? null : id

  if (!idForMap.value) return

  AssertedDistribution.find(id, {
    extend: ['asserted_distribution_shape'],
    embed: ['shape']
  })
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
