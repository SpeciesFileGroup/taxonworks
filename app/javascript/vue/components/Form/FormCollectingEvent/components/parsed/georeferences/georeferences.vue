<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="isModalVisible = !isModalVisible"
    >
      Georeference ({{ count }})
    </button>
    <button
      v-if="!isVerbatimCreated"
      type="button"
      class="button normal-input button-submit margin-small-left"
      :disabled="!verbatimLat && !verbatimLat"
      @click="createVerbatimShape"
    >
      Create georeference from verbatim
    </button>
    <template v-if="isVerbatimCreated">
      <span>
        Lat: {{ verbatimCoordinates.latitude }}, Long:
        {{ verbatimCoordinates.longitude }}
        <span v-if="verbatimRadiusError">
          , Radius error: {{ verbatimRadiusError }}
        </span>
      </span>
    </template>
    <modal-component
      @close="isModalVisible = false"
      :container-style="{
        width: '80vw',
        maxHeight: '80vh',
        overflowY: 'scroll'
      }"
      v-if="isModalVisible"
    >
      <template #header>
        <h3>Georeferences</h3>
      </template>
      <template #body>
        <div style="overflow-y: scroll">
          <div
            class="horizontal-left-content margin-medium-top margin-medium-bottom"
          >
            <wkt-component
              @create="addToQueue"
              class="margin-small-right"
            />
            <manually-component
              class="margin-small-right"
              @create="addGeoreference($event, GEOREFERENCE_POINT)"
            />
            <geolocate-component
              :disabled="!collectingEvent.id"
              class="margin-small-right"
              @create="addToQueue"
            />
            <button
              type="button"
              v-if="verbatimLat && verbatimLng"
              :disabled="isVerbatimCreated"
              @click="createVerbatimShape"
              class="button normal-input button-submit"
            >
              Create georeference from verbatim
            </button>
          </div>
          <div
            :style="{
              height: height,
              width: width
            }"
          >
            <map-component
              ref="leaflet"
              v-if="show"
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
            class="horizontal-left-content margin-medium-top margin-medium-bottom"
          >
            <wkt-component
              @create="addToQueue"
              class="margin-small-right"
            />
            <manually-component
              class="margin-small-right"
              @create="addGeoreference($event, GEOREFERENCE_POINT)"
            />
            <geolocate-component
              class="margin-small-right"
              @create="addToQueue"
            />
            <button
              type="button"
              v-if="verbatimLat && verbatimLng"
              :disabled="isVerbatimCreated"
              @click="createVerbatimShape"
              class="button normal-input button-submit"
            >
              Create georeference from verbatim
            </button>
          </div>
          <display-list
            :list="
              collectingEvent.id
                ? store.georeferences
                : store.queueGeoreferences
            "
            @delete="removeGeoreference"
            @update="updateRadius"
            @date-changed="addToQueue"
            label="object_tag"
          />
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import MapComponent from '@/components/georeferences/map'
import DisplayList from './list'
import convertDMS from '@/helpers/parseDMS.js'
import ManuallyComponent from '@/components/georeferences/manuallyComponent'
import GeolocateComponent from './geolocate'
import ModalComponent from '@/components/ui/Modal'
import WktComponent from './wkt'
import DateComponent from '@/components/ui/Date/DateFields.vue'
import useStore from '../../../store/georeferences.js'
import { addToArray } from '@/helpers'
import { computed, ref, watch } from 'vue'
import { Georeference } from '@/routes/endpoints'
import { truncateDecimal } from '@/helpers/math.js'
import {
  GEOREFERENCE_GEOLOCATE,
  GEOREFERENCE_EXIF,
  GEOREFERENCE_POINT,
  GEOREFERENCE_VERBATIM,
  GEOREFERENCE_WKT,
  GEOREFERENCE_LEAFLET
} from '@/constants/index.js'

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
  },

  show: {
    type: Boolean,
    default: true
  }
})

const collectingEvent = defineModel()
const emit = defineEmits(['onGeoreferences'])
const store = useStore()

const isModalVisible = ref(false)

const shapes = ref({
  type: 'FeatureCollection',
  features: []
})

const date = ref({
  year_georeferenced: undefined,
  month_georeferenced: undefined,
  day_georeferenced: undefined
})

const isVerbatimCreated = computed(() => {
  return []
    .concat(store.georeferences, store.queueGeoreferences)
    .find(
      (item) =>
        item.type === GEOREFERENCE_VERBATIM || item.type === GEOREFERENCE_EXIF
    )
})

const geojson = computed(() => {
  return collectingEvent.value.id
    ? shapes.value.features
    : store.queueGeoreferences
})

const count = computed(() => {
  return geojson.value.filter((item) => !item?.properties?.geographic_area)
    .length
})
const verbatimLat = computed(() => collectingEvent.value.verbatim_latitude)
const verbatimLng = computed(() => collectingEvent.value.verbatim_longitude)

const verbatimCoordinates = computed(() => {
  const shape = isVerbatimCreated.value

  if (shape) {
    const [longitude, latitude] = shape.geo_jso
      ? shape.geo_jso.geometry.coordinates
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
      return truncateDecimal(shape.properties.radius, 6)
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

const mapGeoreferences = computed(() =>
  [].concat(
    shapes.value.features,
    store.queueGeoreferences
      .filter(
        (item) =>
          item.type !== GEOREFERENCE_WKT &&
          item.type !== GEOREFERENCE_GEOLOCATE &&
          item?.geographic_item_attributes?.shape
      )
      .map((item) => JSON.parse(item?.geographic_item_attributes?.shape))
  )
)

watch([() => store.georeferences, () => store.geographicArea], populateShapes, {
  deep: true
})

function updateRadius(geo) {
  const index = geo.id
    ? store.georeferences.findIndex((item) => item.id === geo.id)
    : store.queueGeoreferences.findIndex((item) => item.tmpId === geo.tmpId)

  if (geo.id) {
    store.georeferences[index].error_radius = geo.error_radius
    store.georeferences[index].error_geographic_item_id = geo.geographic_item_id
    store.queueGeoreferences.push(store.georeferences[index])
  } else {
    store.queueGeoreferences[index].error_radius = geo.error_radius
  }
}

function addGeoreference(shape, type = GEOREFERENCE_LEAFLET) {
  addToQueue({
    tmpId: Math.random().toString(36).substr(2, 5),
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

function populateShapes() {
  shapes.value.features = []
  if (store.geographicArea) {
    shapes.value.features.unshift(store.geographicArea)
  }
  store.georeferences.forEach((geo) => {
    if (geo.error_radius != null) {
      geo.geo_json.properties.radius = geo.error_radius
    }
    shapes.value.features.push(geo.geo_json)
  })
}

function removeGeoreference(geo) {
  const index = geo.id
    ? store.georeferences.findIndex((item) => item.id === geo.id)
    : store.queueGeoreferences.findIndex((item) => item.tmpId === geo.tmpId)
  if (geo.id) {
    Georeference.destroy(geo.id).then(() => {
      store.georeferences.splice(index, 1)
      emit('onGeoreferences', store.georeferences)
      populateShapes()
    })
  } else {
    store.queueGeoreferences.splice(index, 1)
  }
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
    geographic_item_attributes: { shape: JSON.stringify(shape) },
    collecting_event_id: collectingEvent.value.id,
    type: GEOREFERENCE_VERBATIM,
    error_radius: collectingEvent.value.verbatim_geolocation_uncertainty
  })
}

function addToQueue(data) {
  addToArray(store.queueGeoreferences, data, { property: 'tmpId' })
  store.processGeoreferenceQueue(collectingEvent.value.id)
}
</script>
