<template>
  <div>
    <label>Longitude</label>
    <input
      type="text"
      v-model="longitude">
    <span 
      :class="{ red: !this.isCoordinate}"
      v-if="!isCoordinate">Can not parse verbatim values</span>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'
import { parseCoordinateCharacters } from 'helpers/georeferences'
import convertDMS from '../../../../helpers/parseDMS.js'

export default {
  computed: {
    isCoordinate () {
      if (this.longitude && this.longitude.length) {
        return convertDMS(this.longitude)
      } else {
        return true
      }
    },
    longitude: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_longitude
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionEventLongitude, parseCoordinateCharacters(value))
      }
    }
  }
}
</script>