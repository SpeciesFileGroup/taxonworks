<template>
  <div id="vue-task-observation-dashboard">
    <div class="flex-separate middle">
      <h1>Observation matrices dashboard</h1>
      <ul class="context-menu">
        <li>
          <a :href="RouteNames.ObservationMatricesHub">Observation matrix hub</a>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeJson">
            Show JSON Request
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter">
            Show filter
          </label>
        </li>
      </ul>
    </div>
    <json-bar
      v-if="activeJson"
      :json-url="jsonUrl"/>
    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        v-show="activeFilter"
        :field-set="['observations']"
        @onSearch="loadRankTable"
        @onTableFilter="tableFilter = $event"
        @reset="resetTask"/>
      <div class="full_width">
        <div
          v-show="Object.keys(rankTable).length"
          class="horizontal-left-content align-start full_width">
          <rank-table
            class="margin-medium-left"
            :filter="tableFilter"
            :table-list="rankTable"/>
        </div>
        <h3
          v-if="!Object.keys(rankTable).length"
          class="subtle middle horizontal-center-content">No records found.
        </h3>
      </div>
    </div>
  </div>
</template>

<script>

import FilterComponent from './components/filter.vue'
import RankTable from './components/table'
import JsonBar from './components/headerBar'

import { TaxonName } from 'routes/endpoints'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { RouteNames } from 'routes/routes'

export default {
  components: {
    FilterComponent,
    RankTable,
    JsonBar
  },
  computed: {
    RouteNames: () => RouteNames,

    rankTable: {
      get () {
        return this.$store.getters[GetterNames.GetRankTable]
      },
      set (value) {
        this.$store.commit(MutationNames.SetRankTable, value)
      }
    }
  },
  data () {
    return {
      activeFilter: true,
      jsonUrl: '',
      activeJson: false,
      limit: 5000,
      tableFilter: undefined
    }
  },
  watch: {
    rankTable: {
      handler (newVal) {
        if (Object.keys(newVal).length && newVal.data.length === this.limit) {
          TW.workbench.alert.create('Result contains 1000 rows, it may be truncated.', 'notice')
        }
      },
      deep: true
    }
  },
  methods: {
    resetTask () {
      this.rankTable = {}
      this.jsonUrl = undefined
      history.pushState(null, null, '/tasks/observation_matrices/dashboard')
    },
    loadRankTable (params) {
      const data = {
        fieldsets: this.fieldSet,
        limit: this.limit
      }
      TaxonName.rankTable({ ...data, ...params }).then(response => {
        const urlParams = new URLSearchParams(response.request.responseURL.split('?')[1])

        this.jsonUrl = response.request.responseURL
        this.rankTable = response.body

        history.pushState(null, null, `/tasks/observation_matrices/dashboard?${urlParams.toString()}`)
      })
    }
  }
}
</script>
<style lang="scss">
  #vue-task-observation-dashboard {
    .header-box {
      height: 30px;
    }
  }
</style>
