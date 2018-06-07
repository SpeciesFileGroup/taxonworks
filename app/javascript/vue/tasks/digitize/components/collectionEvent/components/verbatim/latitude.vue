<template>
  <div>
    <label>Latitude</label>
    <input
      type="text"
      v-model="latitude">
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    latitude: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventLatitude]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLatitude, value)
      }
    }
  }
}
</script>