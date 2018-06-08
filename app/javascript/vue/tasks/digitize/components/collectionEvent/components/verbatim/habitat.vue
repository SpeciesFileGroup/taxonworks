<template>
  <div>
    <label>Habitat</label>
    <input
      type="text"
      v-model="habitat">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    habitat: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_habitat
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventHabitat, value)
      }
    }
  }
}
</script>