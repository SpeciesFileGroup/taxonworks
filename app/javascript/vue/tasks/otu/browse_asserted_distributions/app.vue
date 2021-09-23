<template>
  <div id="vue-task-browse-asserted-distribution-otu">
    <div class="flex-separate middle">
      <h1>Browse asserted distributions</h1>
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
          :list="assertedDistribution"/>
        <h3
          v-if="alreadySearch && !assertedDistribution.length"
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
import { AssertedDistribution } from 'routes/endpoints'

export default {

  components: {
    MapComponent,
    FilterComponent,
    ListComponent
  },

  computed: {
    geojson () {
      return this.assertedDistribution.map(item => item.geographic_area.shape)
    }
  },

  data () {
    return {
      assertedDistribution: [],
      urlRequest: '',
      activeFilter: true,
      activeJSONRequest: false,
      append: false,
      alreadySearch: false,
    }
  },

  methods: {
    searchDistribution (otu) {
      AssertedDistribution.where({
        otu_id: otu.id,
        embed: ['shape', 'geographic_area']
      }).then(response => {
        this.assertedDistribution = response.body
      })
    },

    resetTask () {
      this.alreadySearch = false
      this.urlRequest = ''
      this.assertedDistribution = []
    },

    loadList (newList) {
      if (this.append) {
        let concat = newList.concat(this.assertedDistribution)
        concat = concat.filter((item, index, self) =>
          index === self.findIndex((i) => i.id === item.id)
        )
        this.assertedDistribution = concat
      } else {
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
      width: 400px;
      min-width: 400px;
    }
    :deep(.vue-autocomplete-input) {
      width: 100%;
    }
  }
</style>