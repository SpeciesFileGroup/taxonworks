<template>
  <div>
    <label>Longitude</label>
    <input
      type="text"
      :value="longitude"
      @input="setLongitude">
    <span
      :class="{ red: !this.isCoordinate}"
      v-if="!isCoordinate">Can not parse verbatim values</span>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import { parseCoordinateCharacters } from 'helpers/georeferences'
import convertDMS from 'helpers/parseDMS.js'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  computed: {
    isCoordinate () {
      return this.longitude && this.longitude.length
        ? convertDMS(this.longitude)
        : true
    },

    longitude () {
      return this.$store.getters[GetterNames.GetCollectingEvent].verbatim_longitude
    }
  },

  methods: {
    setLongitude (e) {
      this.collectingEvent.verbatim_longitude = parseCoordinateCharacters(e.target.value)
    }
  }
}
</script>