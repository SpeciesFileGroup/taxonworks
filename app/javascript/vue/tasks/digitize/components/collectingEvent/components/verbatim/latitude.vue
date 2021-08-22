<template>
  <div>
    <label>Latitude</label>
    <input
      type="text"
      :value="collectingEvent.verbatim_latitude"
      @input="setLatitude">
    <span
      v-if="!isCoordinate"
      :class="{ red: !this.isCoordinate}"
    >
      Can not parse verbatim values
    </span>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters'
import convertDMS from '../../../../helpers/parseDMS.js'
import { parseCoordinateCharacters } from 'helpers/georeferences'
import extendCE from '../../mixins/extendCE.js'

export default {
  mixins: [extendCE],

  computed: {
    isCoordinate () {
      return this.latitude && this.latitude.length ? convertDMS(this.latitude) : true
    },

    latitude () {
      return this.$store.getters[GetterNames.GetCollectingEvent].verbatim_latitude
    }
  },

  methods: {
    setLatitude (e) {
      this.collectingEvent.verbatim_latitude = parseCoordinateCharacters(e.target.value)
    }
  }
}
</script>