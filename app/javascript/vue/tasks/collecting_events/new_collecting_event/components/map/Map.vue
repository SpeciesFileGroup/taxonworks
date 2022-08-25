<template>
  <div>
    <div v-show="latitude && longitude">
      <div style="height: 10%; overflow: auto;">
        Map verification
      </div>
      <VMap
        width="100%"
        height="300px"
        resize
        :zoom="5"
        :zoom-bounds="5"
        :geojson="verbatimGeoJSON"
      />
    </div>

    <div
      v-if="(!latitude || !longitude) && (collectingEvent.verbatim_latitude || collectingEvent.verbatim_longitude)"
      class="panel aligner middle"
      style="height: 300px; align-items: center; width:100%; text-align: center;"
    >
      <h3>
        <span class="soft_validation">
          <span data-icon="warning" />
          <span>Verbatim latitude/longitude unparsable or incomplete, location preview unavailable.</span>
        </span>
      </h3>
    </div>

    <div
      v-show="!collectingEvent.verbatim_latitude && !collectingEvent.verbatim_longitude"
      class="panel aligner"
      style="height: 300px; align-items: center; width:100%; text-align: center;"
    >
      <h3>Provide verbatim latitude/longitude to preview location on map.</h3>
    </div>
  </div>
</template>

<script>

import convertDMS from 'helpers/parseDMS.js'
import extendCE from '../mixins/extendCE'
import VMap from 'components/georeferences/map.vue'

export default {
  mixins: [extendCE],

  components: {
    VMap
  },

  computed: {
    latitude () {
      return convertDMS(this.collectingEvent.verbatim_latitude)
    },

    longitude () {
      return convertDMS(this.collectingEvent.verbatim_longitude)
    },

    verbatimGeoJSON () {
      if (this.latitude && this.longitude) {
        return [{
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [this.longitude, this.latitude]
          },
          properties: {
            name: 'Dinagat Islands'
          }
        }]
      } else {
        return []
      }
    }
  }
}
</script>
<style scoped>
.aligner {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
