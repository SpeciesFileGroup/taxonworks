<template>
  <div v-help="helpData.verbatimCoordinatesPrewiew">
    <div v-show="latitude && longitude">
      <div style="height: 10%; overflow: auto">
        Verbatim coordinates preview
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
      v-if="
        (!latitude || !longitude) &&
        (collectingEvent.verbatim_latitude ||
          collectingEvent.verbatim_longitude)
      "
      class="panel aligner middle"
      style="
        height: 300px;
        align-items: center;
        width: 100%;
        text-align: center;
      "
    >
      <h3>
        <span class="soft_validation">
          <span data-icon="warning" />
          <span
            >Verbatim latitude/longitude unparsable or incomplete, location
            preview unavailable.</span
          >
        </span>
      </h3>
    </div>

    <div
      v-show="
        !collectingEvent.verbatim_latitude &&
        !collectingEvent.verbatim_longitude
      "
      class="panel aligner"
      style="
        height: 300px;
        align-items: center;
        width: 100%;
        text-align: center;
      "
    >
      <h3>Provide verbatim latitude/longitude to preview location on map.</h3>
    </div>
  </div>
</template>

<script setup>
import convertDMS from '@/helpers/parseDMS.js'
import VMap from '@/components/georeferences/map.vue'
import helpData from '../../help/en.js'
import { vHelp } from '@/directives'
import { computed } from 'vue'

const collectingEvent = defineModel()

const latitude = computed(() =>
  convertDMS(collectingEvent.value.verbatim_latitude)
)
const longitude = computed(() =>
  convertDMS(collectingEvent.value.verbatim_longitude)
)

const verbatimGeoJSON = computed(() => {
  return latitude.value && longitude.value
    ? [
        {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [longitude.value, latitude.value]
          },
          properties: {
            name: 'Dinagat Islands'
          }
        }
      ]
    : []
})
</script>
<style scoped>
.aligner {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
