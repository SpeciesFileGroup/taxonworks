<template>
  <div>
    <label>Geolocation uncertainty</label>
    <input
      type="text"
      v-model="geolocationUncertainty">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    geolocationUncertainty: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEventGeolocationUncertainty]
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventGeolocationUncertainty, value)
      }
    }
  }
}
</script>