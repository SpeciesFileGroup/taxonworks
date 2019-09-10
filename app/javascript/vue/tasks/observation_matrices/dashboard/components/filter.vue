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
      <taxon-name v-model="taxonName"/>
      <otu-filter v-model="validity"/>
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

export default {
  components: {
    SpinnerComponent,
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
        if (newVal.rank) {
          this.ranks.push(newVal.rank)
        }
        if (newVal.parent && newVal.parent.rank) {
          this.ranks.push(newVal.parent.rank)
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
