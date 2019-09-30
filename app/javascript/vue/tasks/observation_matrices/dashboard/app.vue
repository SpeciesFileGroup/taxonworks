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
        @reset="resetTask"
        @onSearch="loadRankTable"/>
      <div class="full_width">
        <div
          v-show="Object.keys(rankTable).length"
          class="horizontal-left-content align-start full_width">
          <rank-table
            class="separate-right"
            :ranksSelected="ranks"
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

import { GetRanksTable } from './request/resources'

import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'

export default {
  components: {
    FilterComponent,
    RankTable,
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
    },
    combination () {
      return this.$store.getters[GetterNames.GetCombinations]
    },
    rankList () {
      return this.$store.getters[GetterNames.GetRanks]
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
      validity: false,
      limit: 5000
    }
  },
  watch: {
    ranks: {
      handler (newVal) {
        if (newVal.length) {
          //this.loadRankTable()
        }
      },
      deep: true
    },
    rankTable: {
      handler (newVal) {
        if (newVal.data.length === this.limit) {
          TW.workbench.alert.create('Result contains 1000 rows, it may be truncated.', 'notice')
        }
      },
      deep: true
    },
    combination (newVal) {
      if (this.taxon) {
        //this.loadRankTable()
      }
    }
  },
  methods: {
    resetTask () {
      this.list = []
    },
    loadRankTable () {
      const params = {
        ancestor_id: this.taxon.id,
        ranks: this.orderRanks(),
        fieldsets: this.fieldSet,
        validity: this.validity ? true : undefined,
        combination: this.combination,
        limit: this.limit
      }
      GetRanksTable(this.taxon.id, params).then(response => {
        this.jsonUrl = response.url
        this.rankTable = response.body
      })
    },
    orderRanks() {
      let rankNames = [...new Set(this.getRankNames(this.rankList))]
      let ranksOrder = rankNames.filter(rank => {
        return this.ranks.includes(rank)
      })
      return ranksOrder
    },
    getRankNames (list, nameList = []) {
      for (var key in list) {
        if (typeof list[key] === 'object') {
          this.getRankNames(list[key], nameList)
        } else {
          if (key === 'name') {
            nameList.push(list[key])
          }
        }
      }
      return nameList
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
