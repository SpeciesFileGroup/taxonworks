<template>
  <div class="field label-above">
    <label>Longitude</label>
    <input
      class="full_width"
      type="text"
      v-model="longitude">
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'
import { parseCoordinateCharacters } from 'helpers/georeferences'

export default {
  mixins: [extendCE],

  computed:{
    longitude: {
      get () {
        return this.collectingEvent.verbatim_longitude
      },
      set (value) {
        this.collectingEvent.verbatim_longitude = parseCoordinateCharacters(value)
      }
    }
  }
}
</script>
