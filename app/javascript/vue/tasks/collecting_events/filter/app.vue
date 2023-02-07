<template>
  <div>
    <h1>Filter collecting events</h1>

    <FilterLayout
      :pagination="pagination"
      v-model="parameters"
      :object-type="COLLECTING_EVENT"
      :selected-ids="selectedIds"
      :url-request="urlRequest"
      :list="list"
      v-model:append="append"
      @filter="loadList"
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
      <template #nav-right>
        <RadialFilter
          object-type="CollectingEvent"
          :disabled="!selectedIds.length"
          :parameters="{ collecting_event_id: selectedIds }"
        />
      </template>
      <template #facets>
        <filter-component
          class="separate-right"
          v-show="preferences.activeFilter"
          v-model="parameters"
        />
      </template>

      <template #above-table>
        <map-component
          v-if="preferences.showMap"
          :geojson="geojson"
        />
      </template>
      <template #table>
        <list-component
          v-model="selectedIds"
          :list="list"
          @on-row-hover="setRowHover"
          @on-sort="list = $event"
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
import ListComponent from './components/List.vue'
import MapComponent from './components/Map.vue'
import RadialFilter from 'components/radials/linker/radial.vue'
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import { COLLECTING_EVENT } from 'constants/index.js'
import { computed, ref, watch, reactive } from 'vue'
import { chunkArray, sortArray } from 'helpers/arrays'
import { CollectingEvent, Georeference } from 'routes/endpoints'

const CHUNK_ARRAY_SIZE = 40
const extend = ['roles']

const geojson = computed(() => {
  const hoverId = rowHover.value?.id
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
  pagination,
  urlRequest,
  loadPage,
  makeFilterRequest,
  selectedIds,
  resetFilter,
  parameters
} = useFilter(CollectingEvent, {
  listParser: parseList,
  initParameters: { extend }
})

const rowHover = ref()
const georeferences = ref([])

watch(list, (newVal, oldList) => {
  const currIds = newVal.map((item) => item.id)
  const prevIds = oldList.map((item) => item.id)

  if (currIds.length && currIds.some((id) => !prevIds.includes(id))) {
    loadGeoreferences(newVal)
  }
})

const loadList = () => {
  makeFilterRequest({ ...parameters.value, extend }).then((_) => {
    list.value = parseList(list.value)
  })
}

function parseList(list) {
  return list.map((item) => ({
    ...item,
    roles: (item?.collector_roles || [])
      .map((role) => role.person.cached)
      .join('; '),
    identifiers: (item?.identifiers || []).map((i) => i.cached).join('; '),
    start_date: parseStartDate(item),
    end_date: parseEndDate(item)
  }))
}

const loadGeoreferences = async (list = []) => {
  const idLists = chunkArray(
    list.map((ce) => ce.id),
    CHUNK_ARRAY_SIZE
  )
  const promises = idLists.map((ids) =>
    Georeference.where({ collecting_event_id: ids })
  )

  Promise.all(promises).then((responses) => {
    const lists = responses.map((response) => response.body)

    georeferences.value = lists.flat()
    setCEWithGeoreferences()
  })
}

const setRowHover = (item) => {
  rowHover.value = item
}

const setCEWithGeoreferences = () => {
  list.value.forEach((ce) => {
    ce.georeferencesCount = georeferences.value.filter(
      (item) => item.collecting_event_id === ce.id
    ).length
  })
}

const parseStartDate = (ce) => {
  return [ce.start_date_day, ce.start_date_month, ce.start_date_year]
    .filter((date) => date)
    .join('/')
}

const parseEndDate = (ce) => {
  return [ce.end_date_day, ce.end_date_month, ce.end_date_year]
    .filter((date) => date)
    .join('/')
}
</script>
