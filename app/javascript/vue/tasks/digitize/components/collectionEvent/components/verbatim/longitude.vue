<template>
  <div>
    <label>Longitude</label>
    <input
      type="text"
      v-model="longitude">
  </div>
</template>

<script>

import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  computed: {
    longitude: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventLongitude]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLongitude, value)
      }
    }
  }
}
</script>