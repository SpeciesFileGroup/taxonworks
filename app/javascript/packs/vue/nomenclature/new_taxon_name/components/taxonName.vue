<template>
  <div>
    <input class="taxonName-input" type="text" v-model="taxonName">
  </div>
</template>

<script>

const GetterNames = require('../store/getters/getters').GetterNames
const MutationNames = require('../store/mutations/mutations').MutationNames

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
