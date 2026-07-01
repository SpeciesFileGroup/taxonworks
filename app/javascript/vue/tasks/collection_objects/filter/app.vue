<template>
  <div class="margin-medium-top">
    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :selected-ids="sortedSelectedIds"
      :object-type="COLLECTION_OBJECT"
      :list="list"
      :extend-download="extendDownload"
      :csv-options="csvOptions"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, exclude, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, exclude, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-query-right>
        <RadialCollectionObject
          :disabled="!list.length"
          :parameters="parameters"
          :count="pagination?.total || 0"
          @update="() => makeFilterRequest({ ...parameters, extend, exclude })"
        />
        <RadialLoan
          :disabled="!list.length"
          :parameters="parameters"
        />
        <RadialMatrix
          :disabled="!list.length"
          :parameters="parameters"
          :object-type="COLLECTION_OBJECT"
        />
      </template>
      <template #nav-right>
        <div class="horizontal-right-content gap-small">
          <RadialCollectionObject
            :disabled="!list.length"
            :ids="sortedSelectedIds"
            :count="sortedSelectedIds.length"
            @update="
              () => makeFilterRequest({ ...parameters, extend, exclude })
            "
          />
          <RadialLoan
            :disabled="!list.length"
            :ids="sortedSelectedIds"
          />
          <RadialMatrix
            :ids="sortedSelectedIds"
            :disabled="!list.length"
            :object-type="COLLECTION_OBJECT"
          />
          <DeleteCollectionObjects
            :ids="sortedSelectedIds"
            :disabled="!sortedSelectedIds.length"
            @delete="removeCOFromList"
          />
          <span class="separate-left separate-right">|</span>
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
      <template #table>
        <TableResults
          ref="filterListRef"
          v-model="selectedIds"
          v-model:sort-keys="sortKeys"
          v-model:unsaved-view-changes="unsavedViewChanges"
          :backend-sort="true"
          :sortable-keys="sortableKeys"
          :list="list"
          :layout="currentLayout"
          v-model:hide-unfrozen="hideFrozen"
          :preference-key="`tasks::filters::${COLLECTION_OBJECT}`"
          radial-object
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <SortPanel
          v-model:sort-keys="sortKeys"
          :labels="sortLabels"
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
import FilterComponent from './components/filter.vue'
import TableResults from '@/components/Filter/Table/TableResults.vue'
import SortPanel from '@/components/Filter/Table/SortPanel.vue'
import SaveViewButton from '@/components/Filter/Table/SaveViewButton.vue'
import DwcDownload from './components/dwcDownload.vue'
import DeleteCollectionObjects from './components/DeleteCollectionObjects.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import TableLayoutSelector from '@/components/Filter/Table/TableLayoutSelector.vue'
import RadialLoan from '@/components/radials/loan/radial.vue'
import RadialMatrix from '@/components/radials/matrix/radial.vue'
import RadialCollectionObject from '@/components/radials/co/radial.vue'
import { computed, onMounted, ref, useTemplateRef, watch } from 'vue'
import { useUserPreference } from '@/composables'
import { CollectionObject } from '@/routes/endpoints'
import { COLLECTION_OBJECT } from '@/constants/index.js'
import { useTableLayoutConfiguration } from '@/components/Filter/composables/useTableLayoutConfiguration.js'
import { LAYOUTS } from './constants/layouts.js'
import { listParser } from './utils/listParser.js'
import { useCSVOptions, useFilter } from '@/shared/Filter/composition'
import { serializeSortKeys, parseSortParam } from '@/helpers/arrays.js'
import { humanize } from '@/helpers/strings.js'

const extend = [
  'dwc_occurrence',
  'repository',
  'current_repository',
  'collecting_event',
  'taxon_determinations',
  'identifiers',
  'container_item',
  'container'
]

const exclude = ['object_labels']
const hideFrozen = ref(false)

const {
  currentLayout,
  includes,
  layouts,
  properties,
  updatePropertiesPositions,
  saveLayoutPreferences,
  resetPreferences,
  forceUpdatePreference
} = useTableLayoutConfiguration({ layouts: LAYOUTS, model: COLLECTION_OBJECT })

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
} = useFilter(CollectionObject, {
  initParameters: { extend, exclude },
  listParser,
  sortableColumnsResource: 'collection_objects'
})

const csvOptions = useCSVOptions({ layout: currentLayout, list })

const extendDownload = computed(() => [
  {
    label: 'DwC',
    component: DwcDownload,
    bind: {
      params: parameters.value,
      total: pagination.value?.total,
      selectedIds: selectedIds.value,
      nestParameter: 'collection_object_query'
    }
  }
])

function removeCOFromList(ids) {
  L
  list.value = list.value.filter((item) => !ids.includes(item.id))
  selectedIds.value = selectedIds.value.filter((id) => !ids.includes(id))
}

const sortKeysPref = useUserPreference(
  `tasks::filters::${COLLECTION_OBJECT}::sortKeys`,
  []
)
const filterListRef = useTemplateRef('filterListRef')
const unsavedViewChanges = ref(false)

const sortKeys = ref(parseSortParam(parameters.value.sort))

onMounted(() => {
  if (!parameters.value.sort && sortKeysPref.value?.length) {
    sortKeys.value = [...sortKeysPref.value]
  }
})

function sortKeysEqual(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b)) return false
  if (a.length !== b.length) return false
  for (let i = 0; i < a.length; i++) {
    if (a[i]?.key !== b[i]?.key || a[i]?.dir !== b[i]?.dir) return false
  }
  return true
}

const hasUnsavedSortChanges = computed(() =>
  !sortKeysEqual(sortKeys.value, sortKeysPref.value ?? [])
)

const hasUnsavedChanges = computed(
  () => hasUnsavedSortChanges.value || unsavedViewChanges.value
)

function saveViewAsDefault() {
  filterListRef.value?.saveViewAsDefault()
  // Deep-clone to strip Vue reactive proxies. BroadcastChannel.postMessage
  // (used inside useUserPreferences) uses structuredClone, which can't
  // clone Vue proxies.
  sortKeysPref.value = JSON.parse(JSON.stringify(sortKeys.value))
}

const sortLabels = computed(() => {
  const map = {}
  const properties = currentLayout.value?.properties || {}
  for (const [group, cols] of Object.entries(properties)) {
    if (Array.isArray(cols)) {
      const groupLabel = humanize(group)
      for (const col of cols) {
        map[`${group}.${col}`] = `${groupLabel} · ${col}`
      }
    }
  }
  return map
})

watch(
  sortKeys,
  (next) => {
    const sortString = serializeSortKeys(next)
    if (sortString === parameters.value.sort) return
    parameters.value.sort = sortString
    makeFilterRequest({ ...parameters.value, extend, exclude, page: 1 })
  },
  { deep: true }
)

watch(
  () => parameters.value.sort,
  (next) => {
    if (next === serializeSortKeys(sortKeys.value)) return
    sortKeys.value = parseSortParam(next)
  }
)
</script>

<script>
export default {
  name: 'FilterCollectionObjects'
}
</script>
