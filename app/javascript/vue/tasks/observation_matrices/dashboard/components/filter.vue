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
      <button 
        class="button normal-input button-default full_width"
        type="button"
        :disabled="!taxonName"
        @click="$emit('onSearch')">
        Search
      </button>
      <taxon-name v-model="taxonName"/>
      <otu-filter v-model="validity"/>
      <combinations-filter/>
      <ranks-filter
        :taxon-name="taxonName"
        v-model="ranks"/>
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import taxonName from './filters/taxonName'
import RanksFilter from './filters/ranks'
import OtuFilter from './filters/otus'
import CombinationsFilter from './filters/combinations'

export default {
  components: {
    SpinnerComponent,
    CombinationsFilter,
    RanksFilter,
    OtuFilter,
    taxonName
  },
  data () {
    return {
      taxonName: undefined,
      ranks: [],
      searching: false,
      validity: false
    }
  },
  watch: {
    taxonName: {
      handler (newVal) {
        this.ranks = []
        this.$emit('onTaxon', newVal)

        if(!newVal) return
        if (newVal.rank) {
          this.ranks.push(newVal.rank)
        }
      },
      deep: true
    },
    ranks: {
      handler (newVal) {
        if (newVal.length) {
          this.$emit('rankSelected', newVal)
        }
      },
      deep: true
    },
    validity (newVal) {
      this.$emit('onValidity', newVal)
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
