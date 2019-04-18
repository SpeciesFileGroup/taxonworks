<template>
  <input
    @input="autoSave"
    v-model="year_of_publication"
    type="number">
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'

export default {
  computed: {
    taxon() {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    year_of_publication: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonYearPublication]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonYearPublication, value)
        this.$store.commit(MutationNames.UpdateLastChange)
      }
    }
  },
  data() {
    return {
      timeOut: undefined,
      saveTime: 3000
    }
  },
  methods: {
    autoSave() {
      if(this.timeOut) {
        clearTimeout(this.timeOut)
        this.timeOut = null
      }
      this.timeOut = setTimeout(() => {
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
      }, this.saveTime)
    }
  }
}
</script>
