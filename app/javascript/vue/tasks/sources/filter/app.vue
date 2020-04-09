<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter sources</h1>
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
        @params="params = $event"
        @newSearch="newSearch"
        @urlRequest="urlRequest = $event"
        @result="loadList"
        @reset="resetTask"/>
      <div class="full_width">
        <div 
          v-if="recordsFound"
          class="horizontal-left-content flex-separate separate-left separate-bottom">
          <div class="horizontal-left-content">
            <csv-button :list="list"/>
            <span class="separate-left separate-right">|</span>
            <button
              v-if="ids.length"
              type="button"
              @click="ids = []"
              class="button normal-input button-default">
              Unselect all
            </button>
            <button
              v-else
              type="button"
              @click="ids = sourceIDs"
              class="button normal-input button-default">
              Select all
            </button>
            <span class="separate-left separate-right">|</span>
            <button
              @click="getBibtex"
              class="button normal-input button-default">
              Download Bibtex
            </button>
          </div>
          <div>
            <select v-model="per">
              <option
                v-for="records in maxRecords"
                :key="records"
                :value="records">
                {{ records }}
              </option>
            </select>
            records per page.
          </div>
        </div>
        <list-component
          v-model="ids"
          :class="{ 'separate-left': activeFilter }"
          :list="list"/>
        <pagination-component
          class="margin-large-bottom"
          v-if="pagination"
          @nextPage="loadPage"
          :pagination="pagination"/>
        <h2
          v-if="alreadySearch && !list"
          class="subtle middle horizontal-center-content no-found-message">No records found.
        </h2>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from 'components/csvButton'
import PaginationComponent from 'components/pagination'
import GetPagination from 'helpers/getPagination'

import { DownloadBibtex } from './request/resources'

export default {
  components: {
    PaginationComponent,
    FilterComponent,
    ListComponent,
    CsvButton
  },
  computed: {
    csvFields () {
      return []
    },
    recordsFound () {
      return this.list.length
    },
    sourceIDs () {
      return this.list.map(item => { return item.id })
    }
  },
  data () {
    return {
      list: [],
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
      ids: [],
      pagination: undefined,
      maxRecords: [50, 100, 250, 500, 1000],
      per: 500,
      params: undefined
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
      this.list = []
      this.urlRequest = ''
      this.pagination = undefined
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
      }
      else {
        this.list = newList
      }
      this.alreadySearch = true
    },
    newSearch () {
      if (!this.append) {
        this.list = []
      }
    },
    loadPage (event) {
      this.$refs.filterComponent.loadPage(event.page)
    },
    getBibtex () {
      DownloadBibtex(this.params)
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