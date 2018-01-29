<template>
  <input
    v-model="author"
    type="text">
</template>

<script>

const GetterNames = require('../store/getters/getters').GetterNames
const MutationNames = require('../store/mutations/mutations').MutationNames

export default {
  computed: {
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
