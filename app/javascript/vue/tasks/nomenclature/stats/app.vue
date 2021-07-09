<template>
  <div id="vue-task-observation-dashboard">
    <spinner-component
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."/>
    <div class="flex-separate middle">
      <h1>Nomenclature stats</h1>
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
      <div
        v-show="activeFilter"
        class="panel filter separate-right">
        <div class="flex-separate content middle action-line">
          <span>Filter</span>
        </div>
        <div class="content">
          <button
            type="button"
            class="button normal-input button-default full_width"
            @click="loadRankTable">
            Search
          </button>
          <taxon-name-component v-if="Object.keys(rankList).length"/>
          <ranks-filter
            title="Count columns"
            :taxon-name="taxon"
            v-model="rankData"/>
          <combinations-filter/>
          <ranks-filter
            title="Display rows"
            :taxon-name="taxon"
            v-model="ranks"/>
        </div>
      </div>
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

import RankTable from './components/table'
import JsonBar from './components/headerBar'
import TaxonNameComponent from './components/filters/taxonName'
import RanksFilter from './components/filters/ranks'
import CombinationsFilter from './components/filters/combinations'
import SpinnerComponent from 'components/spinner'

import { TaxonName } from 'routes/endpoints'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'

export default {
  components: {
    SpinnerComponent,
    RanksFilter,
    TaxonNameComponent,
    CombinationsFilter,
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

    combinations () {
      return this.$store.getters[GetterNames.GetCombinations]
    },

    rankList () {
      return this.$store.getters[GetterNames.GetRanks]
    },

    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },

  data () {
    return {
      activeFilter: true,
      fieldSet: ['nomenclatural_stats'],
      ranks: [],
      rankData: [],
      jsonUrl: '',
      activeJson: false,
      limit: 1000,
      isLoading: false,
      halt: false
    }
  },

  watch: {
    rankTable: {
      handler (newVal) {
        if (newVal.data.length === this.limit) {
          TW.workbench.alert.create('Result contains 1000 rows, it may be truncated.', 'notice')
        }
      },
      deep: true
    },
    taxon (newVal) {
      this.halt = true
      this.ranks = []
      this.rankData = []
      this.ranks.push(newVal.rank)
      this.rankData.push(newVal.rank)
    }
  },

  methods: {
    resetTask () {
      this.list = []
    },

    loadRankTable () {
      const params = {
        ancestor_id: this.taxon.id,
        ranks: this.orderRanks(this.ranks),
        fieldsets: this.fieldSet,
        combinations: this.combinations,
        rank_data: this.rankData.length ? this.orderRanks(this.rankData) : undefined,
        validity: true,
        limit: this.limit
      }
      this.isLoading = true
      TaxonName.rankTable(params).then(response => {
        this.jsonUrl = response.request.responseURL
        this.rankTable = response.body
      }).finally(() => {
        this.isLoading = false
      })
    },

    orderRanks (list) {
      const rankNames = [...new Set(this.getRankNames(this.rankList))]

      return rankNames.filter(rank => list.includes(rank))
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
    .filter {
      min-width: 300px;
    }
    :deep(.vue-autocomplete-input) {
      width: 100%;
    }
  }
</style>