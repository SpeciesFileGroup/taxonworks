<template>
  <div>
    <label>Collectors</label>
    <input
      type="text"
      v-model="collectors">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    collectors: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventCollectors]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventCollectors, value)
      }
    }
  }
}
</script>