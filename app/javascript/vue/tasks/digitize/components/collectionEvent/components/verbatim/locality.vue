<template>
  <div>
    <label>Locality</label>
    <input
      type="text"
      v-model="locality">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    locality: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventLocality]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLocality, value)
      }
    }
  }
}
</script>