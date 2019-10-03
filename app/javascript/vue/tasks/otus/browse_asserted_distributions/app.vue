<template>
  <div id="vue-task-browse-asserted-distribution-otu">
    <div class="flex-separate middle">
      <h1>Otu distributions</h1>
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
        class="separate-right filter"
        v-show="activeFilter"
        @urlRequest="urlRequest = $event"
        @result="loadList"
        @reset="resetTask"/>
      <div class="full_width">
        <div class="panel container">
          <map-component
            :lat="0"
            :lng="0"
            :zoom="1"
            width="100%"
            height="80vh"
            :geojson="geojson"
            :resize="true"/>
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

import MapComponent from 'components/georeferences/map.vue'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvComponent from 'components/csvButton.vue'

import { GetOtuAssertedDistribution } from './request/resources'

export default {
  components: {
    MapComponent,
    FilterComponent,
    ListComponent,
    CsvComponent
  },
  computed: {
    geojson() {
      if(this.assertedDistribution.length) {
        return this.assertedDistribution.map(item => { return item.geographic_area.geo_json })
      }
      return []
    }
  },
  data () {
    return {
      assertedDistribution: [],
      list: [],
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
    }
  },
  methods: {
    searchDistribution(otu) {
      GetOtuAssertedDistribution(otu.id).then(response => {
        this.assertedDistribution = response.body
      })
    },
    resetTask() {
      this.alreadySearch = false
      this.list = []
      this.urlRequest = ''
    },
    loadList(newList) {
      if(this.append) {
        let concat = newList.concat(this.assertedDistribution)
              
        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => (
            i.id === item.id
          ))
        )
        this.assertedDistribution = concat
      }
      else {
        this.assertedDistribution = newList
      }
      this.alreadySearch = true
    }
  }
}
</script>
<style lang="scss">
  #vue-task-browse-asserted-distribution-otu {
    .header-box {
      height: 30px;
    }
    .filter {
      width: 300px;
      min-width: 300px;
    }
    /deep/ .vue-autocomplete-input {
      width: 100%;
    }
  }
</style>