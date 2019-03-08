<template>
  <div>
    <label>Latitude</label>
    <input
      type="text"
      v-model="latitude">
    <span
      v-if="!isCoordinate"
      :class="{ red: !this.isCoordinate}">Can not parse verbaitm values
    </span>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'
import convertDMS from '../../../../helpers/parseDMS.js'

export default {
  computed: {
    isCoordinate() {
      if(this.latitude && this.latitude.length) {
        return convertDMS(this.latitude)
      }
      else {
        return true
      }
    },
    latitude: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_latitude
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionEventLatitude, value)
      }
    }
  }
}
</script>