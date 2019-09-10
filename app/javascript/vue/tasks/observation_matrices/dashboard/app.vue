<template>
  <div id="vue-task-observation-dashboard">
    <div class="flex-separate middle">
      <h1>Observation matrices dashboard</h1>
      <ul class="context-menu">
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
        @rankSelected="ranks = $event"
        @onTaxon="taxon = $event"
        @onValidity="validity = $event"
        @reset="resetTask"/>
      <div class="full_width">
        <div
          v-show="Object.keys(rankTable).length"
          class="horizontal-left-content align-start">
          <rank-table
            class="separate-right"
            :table-list="rankTable"/>
          <table-fixed
            class="separate-left full_width"
            :table-values="rankTable" />
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
import TableFixed from './components/tableFixed'
import JsonBar from './components/headerBar'

import { GetRanksTable } from './request/resources'

import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'

export default {
  components: {
    FilterComponent,
    RankTable,
    TableFixed,
    JsonBar
  },
  computed: {
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
      taxon: undefined,
      fieldSet: ['observations'],
      ranks: [],
      jsonUrl: '',
      activeJson: false,
      validity: false
    }
  },
  watch: {
    ranks: {
      handler (newVal) {
        if (newVal.length) {
          this.loadRankTable()
        }
      },
      deep: true
    }
  },
  methods: {
    resetTask () {
      this.list = []
    },
    loadRankTable () {
      const params = { 
        ancestor_id: this.taxon.id,
        ranks: this.ranks,
        fieldsets: this.fieldSet,
        validity: this.validity ? true : undefined
      }
      GetRanksTable(this.taxon.id, params).then(response => {
        this.jsonUrl = response.url
        this.rankTable = response.body
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