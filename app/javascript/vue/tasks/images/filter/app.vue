<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter images</h1>
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
        @response="updateUrl"
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
        <div
          :class="{ 'separate-left': activeFilter }"
        >
          <div class="panel content margin-medium-bottom">
            <div class="horizontal-left-content">
              <tag-all
                type="Image"
                :ids="idsSelected"
              />
              <div class="margin-small-left">
                <select-all
                  v-model="idsSelected"
                  :ids="list.map(({id}) => id)"
                />
              </div>
            </div>
          </div>
          <list-component
            v-model="idsSelected"
            :list="list"/>
          <h2
            v-if="alreadySearch && !list.length"
            class="subtle middle horizontal-center-content no-found-message">No records found.
          </h2>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import PaginationComponent from 'components/pagination'
import getPagination from 'helpers/getPagination'
import PlatformKey from 'helpers/getPlatformKey'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import SelectAll from 'tasks/collection_objects/filter/components/selectAll.vue'

export default {
  components: {
    PaginationComponent,
    FilterComponent,
    ListComponent,
    TagAll,
    SelectAll
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
      params: undefined,
      idsSelected: []
    }
  },

  watch: {
    per (newVal) {
      this.$refs.filterComponent.params.settings.per = newVal
      this.loadPage(1)
    }
  },

  created () {
    TW.workbench.keyboard.createLegend(`${PlatformKey()}+f`, 'Search', 'Filter sources')
    TW.workbench.keyboard.createLegend(`${PlatformKey()}+r`, 'Reset task', 'Filter sources')
  },

  methods: {
    resetTask () {
      this.alreadySearch = false
      this.list = []
      this.urlRequest = ''
      this.pagination = undefined
      history.pushState(null, null, '/tasks/images/filter')
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

    updateUrl (response) {
      getPagination(response)
      const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])
      history.pushState(null, null, `/tasks/images/filter?${urlParams.toString()}`)
    },

    getPagination
  }
}
</script>
<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>
