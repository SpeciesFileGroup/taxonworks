<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter nomenclature</h1>
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
          <csv-component :list="list"/>
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
        v-show="activeFilter"
        ref="filterComponent"
        @urlRequest="urlRequest = $event"
        @result="loadList"
        @pagination="pagination = getPagination($event)"
        @reset="resetTask"/>
      <div class="full_width">
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
              class="horizontal-left-content">{{ list.length }} records.
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
          :class="{ 'separate-left': activeFilter }"
          :list="list"/>
        <h3
          v-if="alreadySearch && !list.length"
          class="subtle middle horizontal-center-content">No records found.
        </h3>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvComponent from './components/convertCsv'
import PaginationComponent from 'components/pagination'
import GetPagination from 'helpers/getPagination'

export default {
  components: {
    FilterComponent,
    ListComponent,
    CsvComponent,
    PaginationComponent
  },
  data () {
    return {
      list: [],
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
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
      this.list = []
      this.urlRequest = ''
      history.pushState(null, null, '/tasks/taxon_names/filter')
    },
    loadList(newList) {
      if(this.append) {
        let concat = newList.concat(this.list)
              
        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => (
            i.id === item.id
          ))
        )
        this.list = concat
      }
      else {
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
