<template>
  <input
    v-model="author"
    type="text">
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  computed: {
    taxon() {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    author: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonAuthor]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonAuthor, value)
        this.$store.commit(MutationNames.UpdateLastChange)
      }
    }
  }
}
</script>
