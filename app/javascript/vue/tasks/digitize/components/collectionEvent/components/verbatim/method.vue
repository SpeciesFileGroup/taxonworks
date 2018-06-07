<template>
  <div>
    <label>Method</label>
    <input
      type="text"
      v-model="method">
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    method: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventMethod]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventMethod, value)
      }
    }
  }
}
</script>