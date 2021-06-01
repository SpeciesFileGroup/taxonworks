<template>
  <div>
    <label>Latitude</label>
    <input
      type="text"
      v-model="latitude">
    <span
      v-if="!isCoordinate"
      :class="{ red: !this.isCoordinate}">Can not parse verbatim values
    </span>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'
import convertDMS from '../../../../helpers/parseDMS.js'
import { parseCoordinateCharacters } from 'helpers/georeferences'

export default {
  computed: {
    isCoordinate () {
      return this.latitude && this.latitude.length ? convertDMS(this.latitude) : true
    },

    latitude: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_latitude
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionEventLatitude, parseCoordinateCharacters(value))
      }
    }
  }
}
</script>