<template>
  <div>
    <label>Repository</label>
    <autocomplete
      url="/repositories/autocomplete"
      label="label_html"
      param="term"
      @getItem="repository = $event.id"
      min="2"/>
  </div>
</template>

<script>

import Autocomplete from '../../../../components/autocomplete'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  components: {
    Autocomplete
  },
  computed: {
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    repository: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].repository_id
      },
      set(value) {
        return this.$store.commit(MutationNames.SetCollectionObjectRepositoryId, value)
      }
    }
  },
}
</script>

<style>

</style>
