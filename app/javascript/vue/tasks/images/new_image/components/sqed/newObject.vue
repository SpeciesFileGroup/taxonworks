<template>
  <div>
    <div class="horizontal-left-content align-start">
      <taxon-determination class="separate-right"/>
      <fieldset class="separate-left">
        <legend>New object attributes</legend>
        <label>Total</label>
        <input 
          type="number"
          v-model="collectionObject.total">
      </fieldset>
    </div>
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
