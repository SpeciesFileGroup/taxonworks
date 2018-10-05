<template>
  <div>
    <input
      class="taxonName-input"
      type="text"
      v-model="taxonName">
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  computed: {
    taxonName: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonName]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonName, value)
      }
    }
  }
}
</script>
