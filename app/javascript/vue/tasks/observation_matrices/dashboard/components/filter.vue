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
      <taxon-name v-model="store.taxonName"/>
      <ranks-filter
        :taxon-name="store.taxonName"
        v-model="store.ranks"/>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import GetMacKey from 'helpers/getMacKey.js'
import taxonName from './filters/taxonName'
import RanksFilter from './filters/ranks'

export default {
  components: {
    SpinnerComponent,
    RanksFilter,
    taxonName
  },
  computed: {
    getMacKey () {
      return GetMacKey()
    }
  },
  data () {
    return {
      store: this.initParams(),
      result: [],
      searching: false
    }
  },
  methods: {
    resetFilter () {
      this.$emit('reset')
      this.store = this.initParams()
    },
    searchForTaxonNames () {

    },
    initParams () {
      return {
        taxonName: undefined,
        ranks: []
      }
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
