<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter collection objects</h1>
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
      <div class="full_width overflow-x-auto">
        <div
          v-if="recordsFound"
          class="horizontal-left-content flex-separate separate-bottom">
          <div class="horizontal-left-content">
            <select-all
              v-model="ids"
              :ids="coIds"
            />
            <span class="separate-left separate-right">|</span>
            <csv-button
              :url="urlRequest"
              :options="{ fields: csvFields }"
            />
            <dwc-download
              class="margin-small-left"
              :params="$refs.filterComponent.parseParams"
              :total="pagination.total"
            />
            <dwc-reindex
              class="margin-small-left"
              :params="$refs.filterComponent.parseParams"
              :total="pagination.total"
            />
            <OpenCollectingEventFilter :ids="ids" />
            <match-button
              :ids="ids"
              :url="urlRequest"
              class="margin-small-left"
            />
          </div>
        </div>
        <div
          v-if="pagination"
          class="flex-separate margin-medium-bottom"
        >
          <pagination-component
            v-if="pagination"
            @next-page="loadPage"
            :pagination="pagination"
          />
          <pagination-count
            :pagination="pagination"
            v-model="per"
          />
        </div>
        <list-component
          v-if="Object.keys(list).length"
          v-model="ids"
          :list="list"
          @on-sort="list.data = $event"
        />
        <h2
          v-if="alreadySearch && !list"
          class="subtle middle horizontal-center-content no-found-message"
        >
          No records found.
        </h2>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from './components/csvDownload'
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount'
import GetPagination from 'helpers/getPagination'
import DwcDownload from './components/dwcDownload.vue'
import DwcReindex from './components/dwcReindex.vue'
import SelectAll from './components/selectAll.vue'
import MatchButton from './components/matchButton.vue'
import OpenCollectingEventFilter from './components/OpenCollectingEventFilter.vue'

export default {
  name: 'FilterCollectionObjects',

  components: {
    PaginationComponent,
    FilterComponent,
    ListComponent,
    CsvButton,
    PaginationCount,
    DwcDownload,
    DwcReindex,
    SelectAll,
    MatchButton,
    OpenCollectingEventFilter
  },

  computed: {
    csvFields () {
      if (!Object.keys(this.list).length) return []
      return this.list.column_headers.map((item, index) => {
        return {
          label: item,
          value: (row, field) => row[index] || field.default,
          default: ''
        }
      })
    },

    coIds () {
      return Object.keys(this.list).length ? this.list.data.map(item => item[0]) : []
    },

    recordsFound () {
      return Object.keys(this.list).length && this.list.data.length
    }
  },

  data () {
    return {
      list: {},
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
      ids: [],
      pagination: undefined,
      maxRecords: [50, 100, 250, 500, 1000],
      per: 500
    }
  },

  watch: {
    per (newVal) {
      this.$refs.filterComponent.params.settings.per = newVal
      this.loadPage(1)
    }
  },

  methods: {
    resetTask () {
      this.alreadySearch = false
      this.list = {}
      this.urlRequest = ''
      this.pagination = undefined
      history.pushState(null, null, '/tasks/collection_objects/filter')
    },

    loadList (newList) {
      if (this.append && this.list) {
        let concat = newList.data.concat(this.list.data)

        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => (
            i[0] === item[0]
          ))
        )
        newList.data = concat
        this.list = newList
      } else {
        this.list = newList
      }
      this.alreadySearch = true
    },

    loadPage (event) {
      this.$refs.filterComponent.loadPage(event.page)
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
