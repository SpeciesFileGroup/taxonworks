<template>
  <input
    v-model="year_of_publication"
    type="number">
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

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
  }
}
</script>
