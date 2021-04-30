<template>
  <div class="field label-above">
    <label>Latitude</label>
    <input
      class="full_width"
      type="text"
      v-model="latitude">
  </div>
</template>

<script>

import extendCE from '../mixins/extendCE'
import { parseCoordinateCharacters } from 'helpers/georeferences'

export default {
  mixins: [extendCE],

  computed: {
    latitude: {
      get () {
        return this.collectingEvent.verbatim_latitude
      },
      set (value) {
        this.collectingEvent.verbatim_latitude = parseCoordinateCharacters(value)
      }
    }
  }
}
</script>
