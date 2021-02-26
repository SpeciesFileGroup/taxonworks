<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter sources</h1>
      <ul class="context-menu">
        <li>
          <a href="/tasks/sources/hub">Source hub</a>
        </li>
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
        @pagination="pagination = getPagination($event)"
        @result="loadList"
        @reset="resetTask"/>
      <div class="full_width">
        <div
          v-if="recordsFound"
          class="horizontal-left-content flex-separate separate-left separate-bottom">
          <div class="horizontal-left-content">
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
            <csv-button :list="csvList"/>
            <span class="separate-left separate-right">|</span>
            <bibliography-button
              :selected-list="ids"
              :pagination="pagination"
              :params="params"/>
            <span class="separate-left separate-right">|</span>
            <bibtex-button
              :selected-list="ids"
              :pagination="pagination"
              :params="params"/>
          </div>
        </div>
        <div
          class="flex-separate margin-medium-bottom"
          :class="{ 'separate-left': activeFilter }">
          <pagination-component
            v-if="pagination && list.length"
            @nextPage="loadPage"
            :pagination="pagination"/>
          <div
            v-if="list.length"
            class="horizontal-left-content">
            <span
              class="horizontal-left-content">
              {{ recordsAtCurrentPage }} - 
              {{ recordsAtNextPage }} of {{ pagination.total }} records.
            </span>
            <div class="margin-small-left">
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
        </div>
        <list-component
          v-model="ids"
          :class="{ 'separate-left': activeFilter }"
          :list="list"/>
        <h3
          v-if="alreadySearch && !list.length"
          class="subtle middle horizontal-center-content no-found-message">No records found.
        </h3>
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
import BibtexButton from './components/bibtex'
import BibliographyButton from './components/bibliography.vue'
import PlatformKey from 'helpers/getMacKey'

export default {
  components: {
    PaginationComponent,
    FilterComponent,
    ListComponent,
    CsvButton,
    BibtexButton,
    BibliographyButton
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
    },
    csvList () {
      return this.ids.length ? this.list.filter(item => { return this.ids.includes(item.id) }) : this.list
    },
    recordsAtCurrentPage () {
      return ((this.pagination.paginationPage - 1) * this.pagination.perPage) || 1
    },
    recordsAtNextPage () {
      const recordsCount = this.pagination.paginationPage * this.pagination.perPage
      return recordsCount > this.pagination.total ? this.pagination.total : recordsCount
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
  mounted () {
    TW.workbench.keyboard.createLegend(`${PlatformKey()}+f`, 'Search', 'Filter sources')
    TW.workbench.keyboard.createLegend(`${PlatformKey()}+r`, 'Reset task', 'Filter sources')
  },
  methods: {
    resetTask () {
      this.alreadySearch = false
      this.list = []
      this.urlRequest = ''
      this.pagination = undefined
      history.pushState(null, null, '/tasks/sources/filter')
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
    newSearch () {
      if (!this.append) {
        this.list = []
      }
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