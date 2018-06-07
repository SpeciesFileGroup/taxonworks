<template>
  <div>
    <label>Label</label>
    <input
      type="text"
      v-model="label">
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    label: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventLabel]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLabel, value)
      }
    }
  }
}
</script>