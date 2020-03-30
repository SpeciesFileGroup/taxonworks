<template>
  <div>
    <fieldset>
      <legend>New object attributes</legend>
      <div class="separate-bottom">
        <label>Total</label>
        <input 
          type="number"
          v-model="collectionObject.total">
      </div>
    </fieldset>
    <repository-component/>
    <preparation-type/>
    <taxon-determination class="separate-top"/>
  </div>
</template>

<script>

import TaxonDetermination from './determination'
import RepositoryComponent from './repository'
import PreparationType from './preparationType'

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  components: {
    TaxonDetermination,
    RepositoryComponent,
    PreparationType
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
