<template>
  <div
    class="panel"
    v-help="helpData.verbatimCoordinatesPrewiew"
  >
    <div>
      <div>
        <VMap
          width="100%"
          height="300px"
          resize
          :zoom="5"
          :zoom-bounds="5"
          :geojson="geojson"
        />

        <div
          v-if="
            (!latitude || !longitude) &&
            (collectingEvent.verbatim_latitude ||
              collectingEvent.verbatim_longitude)
          "
          class="flex-col justify-center middle text-center full_width"
        >
          <span>
            Verbatim latitude/longitude unparsable or incomplete, location
            preview unavailable.
          </span>
        </div>
      </div>
      <MapLegend
        v-if="geojson.length"
        :types="currentTypes"
        :preview="!isVerbatimCreated && latitude && longitude"
      />
    </div>
  </div>
</template>

<script setup>
import convertDMS from '@/helpers/parseDMS.js'
import VMap from '@/components/ui/VMap/VMap.vue'
import helpData from '../../help/en.js'
import useCollectingEventStore from '../../store/collectingEvent.js'
import useGeoreferenceStore from '../../store/georeferences.js'
import MapLegend from './MapLegend.vue'
import { vHelp } from '@/directives'
import { computed } from 'vue'
import {
  GEOGRAPHIC_AREA,
  GEOREFERENCE_VERBATIM,
  GEOREFERENCE_GEOLOCATE,
  GEOREFERENCE_WKT
} from '@/constants'

const collectingEvent = defineModel()

const georeferenceStore = useGeoreferenceStore()
const store = useCollectingEventStore()

const currentTypes = computed(() => {
  const types = georeferenceStore.georeferences.map((g) => g.type)

  if (store.geographicArea?.has_shape) {
    types.unshift(GEOGRAPHIC_AREA)
  }

  return types
})

const isVerbatimCreated = computed(() =>
  georeferenceStore.georeferences.some((g) => g.type === GEOREFERENCE_VERBATIM)
)

const latitude = computed(() =>
  convertDMS(collectingEvent.value.verbatim_latitude)
)
const longitude = computed(() =>
  convertDMS(collectingEvent.value.verbatim_longitude)
)

const verbatimGeoJSON = computed(() => {
  return latitude.value && longitude.value && !isVerbatimCreated.value
    ? [
        {
          type: 'Feature',
          properties: {
            style: {
              className: 'map-point-marker bg-verbatim'
            }
          },
          geometry: {
            type: 'Point',
            coordinates: [longitude.value, latitude.value]
          }
        }
      ]
    : []
})

const geojson = computed(() => {
  const { geographicArea } = store
  const features = [...georeferenceStore.geojson, ...verbatimGeoJSON.value]

  if (geographicArea?.has_shape) {
    features.unshift(geographicArea.shape)
  }

  return features
})
</script>
