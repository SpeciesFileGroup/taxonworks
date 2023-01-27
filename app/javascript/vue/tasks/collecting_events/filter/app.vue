<template>
  <div>
    <h1>Filter collecting events</h1>

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
      :object-type="COLLECTING_EVENT"
      :selected-ids="selectedIds"
      v-model:per="per"
      v-model:preferences="preferences"
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
        <span class="separate-left separate-right">|</span>
        <CsvButton :list="list" />
      </template>
      <template #facets>
        <filter-component
          class="separate-right"
          v-show="preferences.activeFilter"
          v-model="parameters"
        />
      </template>

      <template #table>
        <div>
          <div class="full_width">
            <map-component
              v-if="preferences.showMap"
              class="full_width"
              :geojson="geojson"
            />
            <list-component
              v-if="preferences.showList"
              v-model="selectedIds"
              :list="list"
              @on-row-hover="setRowHover"
              @on-sort="list = $event"
            />
          </div>
        </div>
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
import CsvButton from 'components/csvButton'
import MapComponent from './components/Map.vue'
import RadialFilter from 'components/radials/linker/radial.vue'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import { COLLECTING_EVENT } from 'constants/index.js'
import { URLParamsToJSON } from 'helpers/url/parse'
import { computed, ref, watch, reactive, onBeforeMount } from 'vue'
import { chunkArray } from 'helpers/arrays'
import { CollectingEvent, Georeference } from 'routes/endpoints'

const CHUNK_ARRAY_SIZE = 40
const extend = ['roles']

const geojson = computed(() => {
  const ceId = rowHover.value?.id
  const items = ceId
    ? georeferences.value.filter((item) => item.collecting_event_id === ceId)
    : georeferences.value

  return items.map((georeference) => {
    const geojson = georeference.geo_json

    geojson.properties.marker = {
      icon: georeference.collecting_event_id === ceId ? 'green' : 'blue'
    }

    return geojson
  })
})

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false,
  showMap: false,
  showList: true
})

const {
  append,
  isLoading,
  list,
  pagination,
  per,
  urlRequest,
  loadPage,
  makeFilterRequest,
  resetFilter,
  parameters
} = useFilter(CollectingEvent)

const selectedIds = ref([])
const rowHover = ref()
const georeferences = ref([])

watch(per, () => {
  loadPage(1)
})

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

const parseList = (list) => {
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

onBeforeMount(() => {
  parameters.value = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('filterQuery'))
  }

  sessionStorage.removeItem('filterQuery')

  if (Object.keys(parameters.value).length) {
    makeFilterRequest({
      ...parameters.value,
      extend
    }).then((_) => {
      list.value = parseList(list.value)
    })
  }
})
</script>
