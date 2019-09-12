<template>
  <div class="panel filter">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
    </div>
    <spinner-component
      :full-screen="true"
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="searching"
    />
    <div class="content">
      <taxon-name />
      <ranks-filter
        title="Count columns"
        :taxon-name="taxonName"
        v-model="ranks"/>
      <combinations-filter/>
      <ranks-filter
        title="Display rows"
        :taxon-name="taxonName"
        v-model="rankData"/>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import taxonName from './filters/taxonName'
import RanksFilter from './filters/ranks'
import CombinationsFilter from './filters/combinations'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    SpinnerComponent,
    CombinationsFilter,
    RanksFilter,
    taxonName
  },
  computed: {
    taxonName () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    tableList: {
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
      ranks: [],
      searching: false,
      rankData: []
    }
  },
  watch: {
    taxonName: {
      handler (newVal) {
        this.ranks = []
        this.$emit('onTaxon', newVal)
        if (newVal.rank) {
          this.ranks.push(newVal.rank)
          this.rankData.push(newVal.rank)
        }
      },
      deep: true
    },
    ranks: {
      handler (newVal, oldVal) {
        if (newVal.length) {
          this.$emit('rankSelected', newVal)
        }
      },
      deep: true
    },
    rankData: {
      handler (newVal) {
        this.$emit('onDisplayRow', newVal)
      },
      deep: true
    }
  }
}
</script>
<style scoped>
  .filter {
    min-width: 300px;
  }
  /deep/ .vue-autocomplete-input {
    width: 100%;
  }
</style>
