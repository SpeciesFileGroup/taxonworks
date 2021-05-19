<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter collecting events</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter">
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeJSONRequest">
            Show JSON Request
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="append">
            Append results
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="showList">
            Show list
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="showMap">
            Show map
          </label>
        </li>
      </ul>
    </div>
    <div
      v-show="activeJSONRequest"
      class="panel content separate-bottom">
      <div class="flex-separate middle">
        <span>
          JSON Request: {{ urlRequest }}
        </span>
      </div>
    </div>

    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        ref="filterComponent"
        v-show="activeFilter"
        @urlRequest="urlRequest = $event"
        @result="loadList"
        @pagination="pagination = getPagination($event)"
        @reset="resetTask"/>
      <div class="full_width overflow-scroll">
        <div
          v-if="list.length"
          class="horizontal-left-content flex-separate separate-left separate-bottom">
          <div class="horizontal-left-content">
            <csv-button
              :list="list"/>
          </div>
        </div>
        <div
          class="flex-separate margin-medium-bottom"
          v-if="pagination">
          <pagination-component
            v-if="pagination"
            @nextPage="loadPage"
            :pagination="pagination"/>
          <pagination-count
            :pagination="pagination"
            v-model="per"/>
        </div>

        <div class="horizontal-left-content align-start">
          <list-component
            v-if="showList"
            v-model="ids"
            :class="{ 'separate-left': activeFilter }"
            :list="list"
            @onRowHover="setRowHover"
            @onSort="list.data = $event"/>
          <map-component
            class="panel content margin-small-left full_width"
            v-if="showMap"
            :geojson="geojson" />
        </div>

        <h2
          v-if="alreadySearch && !list"
          class="subtle middle horizontal-center-content no-found-message">No records found.
        </h2>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/Filter.vue'
import ListComponent from './components/List.vue'
import CsvButton from 'components/csvButton'
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount'
import GetPagination from 'helpers/getPagination'
import MapComponent from './components/Map.vue'
import { Georeference } from 'routes/endpoints'
import { chunkArray } from 'helpers/arrays'

const CHUNK_ARRAY_SIZE = 40

export default {
  components: {
    PaginationComponent,
    FilterComponent,
    ListComponent,
    CsvButton,
    PaginationCount,
    MapComponent
  },

  computed: {
    ceIds () {
      return this.list.map(item => item.id)
    },

    geojson () {
      return this.georeferences.map(georeference => {
        const ceId = this.rowHover?.id
        const geojson = georeference.geo_json

        geojson.properties.marker = {
          icon: georeference.collecting_event_id === ceId
            ? 'red'
            : 'blue'
        }

        return geojson
      })
    }
  },

  data () {
    return {
      list: [],
      georeferences: [],
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
      ids: [],
      pagination: undefined,
      maxRecords: [50, 100, 250, 500, 1000],
      per: 500,
      showList: true,
      showMap: false,
      rowHover: undefined
    }
  },

  watch: {
    per (newVal) {
      this.$refs.filterComponent.params.settings.per = newVal
      this.loadPage(1)
    },
    list (newVal) {
      this.loadGeoreferences(newVal)
    }
  },

  methods: {
    resetTask () {
      this.alreadySearch = false
      this.list = {}
      this.urlRequest = ''
      this.pagination = undefined
      history.pushState(null, null, '/tasks/collecting_events/filter')
    },

    loadList (newList) {
      if (this.append && this.list) {
        let concat = newList.concat(this.list)

        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => (
            i.id === item.id
          ))
        )
        newList = concat
      }
      this.list = newList
      this.alreadySearch = true
    },

    loadPage (event) {
      this.$refs.filterComponent.loadPage(event.page)
    },

    async loadGeoreferences (list) {
      const idLists = chunkArray(list.map(ce => ce.id), CHUNK_ARRAY_SIZE)
      const promises = []

      idLists.forEach(ids => {
        promises.push(Georeference.where({ collecting_event_ids: ids }))
      })

      Promise.all(promises).then(responses => {
        const lists = responses.map(response => response.body)
        this.georeferences = lists.flat()
      })
    },

    setRowHover (item) {
      this.rowHover = item
    },

    getPagination: GetPagination
  }
}
</script>
<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>