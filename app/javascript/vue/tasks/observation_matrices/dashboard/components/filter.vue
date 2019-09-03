<template>
  <div class="panel filter">
    <div class="flex-separate content middle action-line">
      <span>Filter</span>
      <span
        data-icon="reset"
        class="cursor-pointer"
        @click="resetFilter">Reset
      </span>
    </div>
    <spinner-component
      :full-screen="true"
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="searching"
    />
    <div class="content">
      <taxon-name v-model="taxonName"/>
      <otu-filter/>
      <ranks-filter
        :taxon-name="taxonName"
        v-model="ranks"/>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'
import taxonName from './filters/taxonName'
import RanksFilter from './filters/ranks'
import OtuFilter from './filters/otus'

export default {
  components: {
    SpinnerComponent,
    RanksFilter,
    OtuFilter,
    taxonName
  },
  computed: {
    getMacKey () {
      return GetMacKey()
    }
  },
  data () {
    return {
      taxonName: undefined,
      ranks: [],
      result: [],
      searching: false
    }
  },
  watch: {
    taxonName: {
      handler (newVal) {
        this.ranks = []
        if (newVal.rank) {
          this.ranks.push(newVal.rank)
        }
        if (newVal.parent && newVal.parent.rank) {
          this.ranks.push(newVal.parent.rank)
        }
      },
      deep: true
    }
  },
  methods: {
    resetFilter () {
      this.$emit('reset')
      this.taxonName = undefined
      this.ranks = []
    },
    searchForTaxonNames () {

    },
    filterEmptyParams (object) {
      const keys = Object.keys(object)
      keys.forEach(key => {
        if (object[key] === '') {
          delete object[key]
        }
      })
      return object
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
