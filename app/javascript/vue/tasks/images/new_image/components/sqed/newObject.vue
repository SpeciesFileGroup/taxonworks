<template>
  <div>
    <h3>New object attributes</h3>
    <div class="separate-bottom">
      <label>Total</label>
      <input 
        type="number"
        v-model="collectionObject.total">
    </div>
    <taxon-determination class="separate-top"/>
  </div>
</template>

<script>

import TaxonDetermination from './determination'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  components: {
    TaxonDetermination
  },
  computed: {
    collectionObject: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  }
}
</script>

<style scoped>
  label {
    display: block;
  }
</style>
