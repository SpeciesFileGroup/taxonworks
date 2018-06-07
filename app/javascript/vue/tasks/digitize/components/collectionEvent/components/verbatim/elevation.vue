<template>
  <div>
    <label>Elevation</label>
    <input
      type="text"
      v-model="elevation">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    elevation: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventElevation]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventElevation, value)
      }
    }
  }
}
</script>