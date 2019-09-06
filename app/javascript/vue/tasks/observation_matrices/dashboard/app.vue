<template>
  <div id="vue-task-observation-dashboard">
    <div class="flex-separate middle">
      <h1>Observation matrices dashboard</h1>
      <ul class="context-menu">
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

    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        v-show="activeFilter"
        @rankSelected="ranks = $event"
        @onTaxon="taxon = $event"
        @reset="resetTask"/>
      <div class="full_width">
        <div
          v-show="Object.keys(rankTable).length"
          class="horizontal-left-content align-start">
          <rank-table
            class="separate-right"
            :table-ranks="rankTable"/>
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

import { GetRanksTable } from './request/resources'

export default {
  components: {
    FilterComponent,
    RankTable,
    TableFixed
  },
  data () {
    return {
      rankTable: {},
      activeFilter: true,
      taxon: undefined,
      fieldSet: ['observations'],
      ranks: []
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
        fieldsets: this.fieldSet
      }
      GetRanksTable(this.taxon.id, params).then(response => {
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