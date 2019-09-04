<template>
  <div>
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
        @rankTable="loadRankTable"
        @onTaxon="taxon = $event"
        @reset="resetTask"/>
      <div class="full_width">
        <span v-if="taxon">Scoped: {{ taxon.name }}</span>
        <rank-table :table-ranks="rankTable"/>
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

export default {
  components: {
    FilterComponent,
    RankTable
  },
  data () {
    return {
      rankTable: {},
      activeFilter: true,
      taxon: undefined
    }
  },
  methods: {
    resetTask () {
      this.list = []
    },
    loadRankTable (newList) {
      this.rankTable = newList
    }
  }
}
</script>
