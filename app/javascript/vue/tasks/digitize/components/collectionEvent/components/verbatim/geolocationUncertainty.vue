<template>
  <div>
    <label>Geolocation uncertainty in meters</label>
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
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_geolocation_uncertainty
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventGeolocation, value)
      }
    }
  }
}
</script>