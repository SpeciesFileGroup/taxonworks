<template>
  <input
    v-model="year_of_publication"
    type="number">
</template>

<script>
const GetterNames = require('../store/getters/getters').GetterNames
const MutationNames = require('../store/mutations/mutations').MutationNames
export default {
  computed: {
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
