<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="isModalVisible = !isModalVisible"
    >
      Georeference ({{ count }})
    </button>
    <VBtn
      v-if="!isVerbatimCreated"
      class="margin-small-left"
      color="primary"
      medium
      :disabled="!verbatimLat && !verbatimLat"
      @click="createVerbatimShape"
    >
      Create georeference from verbatim
    </VBtn>
    <template v-if="!!isVerbatimCreated">
      <span>
        Lat: {{ verbatimCoordinates.latitude }}, Long:
        {{ verbatimCoordinates.longitude }}
        <span v-if="verbatimRadiusError">
          , Radius error: {{ verbatimRadiusError }}
        </span>
      </span>
    </template>
    <VModal
      v-if="isModalVisible"
      :container-style="{
        width: '80vw',
        maxHeight: '80vh',
        overflowY: 'scroll'
      }"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>Georeferences</h3>
      </template>
      <template #body>
        <div style="overflow-y: scroll">
          <div
            class="horizontal-left-content margin-medium-top margin-medium-bottom gap-small"
          >
            <VWkt @create="addToQueue" />
            <VManually @create="addGeoreference($event, GEOREFERENCE_POINT)" />
            <VGeolocate @create="addToQueue" />
            <VBtn
              v-if="verbatimLat && verbatimLng"
              color="primary"
              medium
              :disabled="!!isVerbatimCreated"
              @click="createVerbatimShape"
            >
              Create georeference from verbatim
            </VBtn>
          </div>
          <div
            :style="{
              height: height,
              width: width
            }"
          >
            <VMap
              ref="leaflet"
              :height="height"
              :width="width"
              :geojson="mapGeoreferences"
              :zoom="zoom"
              fit-bounds
              resize
              :draw-controls="true"
              :draw-polyline="false"
              :cut-polygon="false"
              :removal-mode="false"
              tooltips
              actions
              @geoJsonLayersEdited="updateGeoreference($event)"
              @geoJsonLayerCreated="addGeoreference($event)"
            />
          </div>
          <div class="margin-medium-top">
            <b>Georeference date</b>
            <date-component
              v-model:day="date.day_georeferenced"
              v-model:month="date.month_georeferenced"
              v-model:year="date.year_georeferenced"
            />
          </div>
          <div
            class="horizontal-left-content margin-medium-top margin-medium-bottom gap-small"
          >
            <VWkt @create="addToQueue" />
            <VManually @create="addGeoreference($event, GEOREFERENCE_POINT)" />
            <VGeolocate @create="addToQueue" />
            <VBtn
              v-if="verbatimLat && verbatimLng"
              color="primary"
              medium
              :disabled="!!isVerbatimCreated"
              @click="createVerbatimShape"
            >
              Create georeference from verbatim
            </VBtn>
          </div>
          <DisplayList
            label="object_tag"
            :list="store.georeferences"
            @delete="removeGeoreference"
            @update="updateRadius"
            @date-changed="addToQueue"
          />
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VMap from '@/components/georeferences/map'
import DisplayList from './list'
import convertDMS from '@/helpers/parseDMS.js'
import VManually from '@/components/georeferences/manuallyComponent'
import VGeolocate from './geolocate'
import VModal from '@/components/ui/Modal'
import VWkt from './wkt'
import DateComponent from '@/components/ui/Date/DateFields.vue'
import useStore from '../../../store/georeferences.js'
import useCEStore from '../../../store/collectingEvent.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import { addToArray, randomUUID } from '@/helpers'
import { computed, ref, watch } from 'vue'
import { truncateDecimal } from '@/helpers/math.js'
import {
  GEOREFERENCE_GEOLOCATE,
  GEOREFERENCE_EXIF,
  GEOREFERENCE_POINT,
  GEOREFERENCE_VERBATIM,
  GEOREFERENCE_WKT,
  GEOREFERENCE_LEAFLET
} from '@/constants/index.js'

const EXCLUDE = [GEOREFERENCE_GEOLOCATE, GEOREFERENCE_WKT]

const props = defineProps({
  height: {
    type: String,
    default: '500px'
  },

  width: {
    type: String,
    default: 'auto'
  },

  geolocationUncertainty: {
    type: [String, Number],
    default: undefined
  },

  zoom: {
    type: Number,
    default: 1
  }
})

const collectingEvent = defineModel()
const store = useStore()
const ceStore = useCEStore()

const isModalVisible = ref(false)

const date = ref({
  year_georeferenced: undefined,
  month_georeferenced: undefined,
  day_georeferenced: undefined
})

const isVerbatimCreated = computed(() => {
  return store.georeferences.find(
    (item) =>
      item.type === GEOREFERENCE_VERBATIM || item.type === GEOREFERENCE_EXIF
  )
})

const count = computed(() => {
  return store.georeferences.length
})
const verbatimLat = computed(() => collectingEvent.value.verbatim_latitude)
const verbatimLng = computed(() => collectingEvent.value.verbatim_longitude)

const verbatimCoordinates = computed(() => {
  const shape = isVerbatimCreated.value

  if (shape) {
    const [longitude, latitude] = shape.geo_json
      ? shape.geo_json.geometry.coordinates
      : JSON.parse(isVerbatimCreated.value.geographic_item_attributes.shape)
          .geometry.coordinates

    return {
      latitude: truncateDecimal(latitude),
      longitude: truncateDecimal(longitude)
    }
  }

  return {}
})

const verbatimRadiusError = computed(() => {
  const shape = isVerbatimCreated.value

  if (shape) {
    if (shape.geo_json) {
      return truncateDecimal(shape.geo_json.properties.radius || 0, 6)
    } else {
      return truncateDecimal(
        JSON.parse(isVerbatimCreated.value.geographic_item_attributes.shape)
          .error_radius,
        6
      )
    }
  }

  return undefined
})

const mapGeoreferences = computed(() => {
  const geographicArea = ceStore.geographicArea
  const georeferences = store.georeferences
    .filter(
      (item) =>
        (item.id || !EXCLUDE.includes(item.type)) &&
        (item?.geographic_item_attributes?.shape || item?.geo_json)
    )
    .map((item) =>
      item.geo_json
        ? item.geo_json
        : JSON.parse(item?.geographic_item_attributes?.shape)
    )

  return geographicArea?.has_shape
    ? [geographicArea.shape, ...georeferences]
    : georeferences
})

function updateRadius(geo) {
  const georeference = store.georeferences.find(
    (item) => item.uuid === geo.uuid
  )

  Object.assign(georeference, {
    error_geographic_item_id: geo.geographic_item_id,
    error_radius: geo.error_radius,
    isUnsaved: true
  })
}

function addGeoreference(shape, type = GEOREFERENCE_LEAFLET) {
  addToQueue({
    uuid: randomUUID(),
    geographic_item_attributes: { shape: JSON.stringify(shape) },
    error_radius: shape.properties?.radius,
    type,
    ...date.value
  })
}

function updateGeoreference(shape, type = GEOREFERENCE_LEAFLET) {
  addToQueue({
    id: shape.properties.georeference.id,
    error_radius: shape.properties?.radius,
    geographic_item_attributes: { shape: JSON.stringify(shape) },
    collecting_event_id: collectingEvent.value.id,
    type
  })
}

function removeGeoreference(geo) {
  store.remove(geo)
}

function createVerbatimShape() {
  const shape = {
    type: 'Feature',
    properties: {},
    geometry: {
      type: 'Point',
      coordinates: [
        convertDMS(verbatimLng.value),
        convertDMS(verbatimLat.value)
      ]
    }
  }

  addToQueue({
    uuid: randomUUID(),
    geographic_item_attributes: { shape: JSON.stringify(shape) },
    collecting_event_id: collectingEvent.value.id,
    type: GEOREFERENCE_VERBATIM,
    error_radius: collectingEvent.value.verbatim_geolocation_uncertainty
  })
}

function addToQueue(data) {
  addToArray(
    store.georeferences,
    {
      ...data,
      isUnsaved: true
    },
    { property: 'uuid' }
  )
}
</script>
