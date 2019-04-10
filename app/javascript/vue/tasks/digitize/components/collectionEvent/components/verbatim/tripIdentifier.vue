<template>
  <div>
    <label>Trip identifier</label>
    <input
      type="text"
      v-model="identifier">
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  computed: {
    identifier: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_trip_identifier
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventTripIdentifier, value)
      }
    }
  }
}
</script>