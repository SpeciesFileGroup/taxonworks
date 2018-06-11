<template>
  <div>
    <label>Locality</label>
    <textarea
      rows="5"
      v-model="locality"/>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    locality: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_locality
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLocality, value)
      }
    }
  }
}
</script>