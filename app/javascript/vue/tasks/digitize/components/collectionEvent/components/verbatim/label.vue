<template>
  <div>
    <label>Label</label>
    <textarea
      rows="5"
      v-model="label"/>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    label: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_label
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLabel, value)
      }
    }
  }
}
</script>