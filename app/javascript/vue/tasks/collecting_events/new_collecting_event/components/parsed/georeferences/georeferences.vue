<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = !showModal">Georeference ({{ count }})</button>
    <button
      v-if="!verbatimGeoreferenceAlreadyCreated"
      type="button"
      class="button normal-input button-submit margin-small-left"
      :disabled="!verbatimLat && !verbatimLat"
      @click="createVerbatimShape">
      Create georeference from verbatim
    </button>
    <template v-if="verbatimGeoreferenceAlreadyCreated">
      <span>Lat: {{ georeferenceVerbatimLatitude }}, Long: {{ georeferenceVerbatimLongitude }}<span v-if="georeferenceVerbatimRadiusError">, Radius error: {{ georeferenceVerbatimRadiusError }}</span></span>
    </template>
    <modal-component
      @close="showModal = false"
      :container-style="{
        width: '80vw',
        maxHeight: '80vh',
        overflowY: 'scroll'
      }"
      v-if="showModal">
      <template #header>
        <h3>Georeferences</h3>
      </template>
      <template #body>
        <div
          style="overflow-y: scroll">
          <div class="horizontal-left-content margin-medium-top margin-medium-bottom">
            <wkt-component
              @create="addToQueue"
              class="margin-small-right"/>
            <manually-component
              class="margin-small-right"
              @create="addGeoreference($event, GEOREFERENCE_POINT)"/>
            <geolocate-component
              :disabled="!collectingEvent.id"
              class="margin-small-right"
              @create="addToQueue"/>
            <button
              type="button"
              v-if="verbatimLat && verbatimLng"
              :disabled="verbatimGeoreferenceAlreadyCreated"
              @click="createVerbatimShape"
              class="button normal-input button-submit">
              Create georeference from verbatim
            </button>
          </div>
          <div
            :style="{
              height: height,
              width: width
            }">
            <spinner-component
              v-if="showSpinner"
              legend="Saving..."/>
            <map-component
              ref="leaflet"
              v-if="show"
              :height="height"
              :width="width"
              :geojson="mapGeoreferences"
              :zoom="zoom"
              :fit-bounds="true"
              :resize="true"
              :draw-controls="true"
              :draw-polyline="false"
              :cut-polygon="false"
              :removal-mode="false"
              @geoJsonLayersEdited="updateGeoreference($event)"
              @geoJsonLayerCreated="addGeoreference($event)"/>
          </div>
          <div class="margin-medium-top">
            <b>Georeference date</b>
            <date-component
              v-model:day="date.day_georeferenced"
              v-model:month="date.month_georeferenced"
              v-model:year="date.year_georeferenced"
            />
          </div>
          <div class="horizontal-left-content margin-medium-top margin-medium-bottom">
            <wkt-component
              @create="addToQueue"
              class="margin-small-right"/>
            <manually-component
              class="margin-small-right"
              @create="addGeoreference($event, GEOREFERENCE_POINT)"/>
            <geolocate-component
              class="margin-small-right"
              @create="addToQueue"/>
            <button
              type="button"
              v-if="verbatimLat && verbatimLng"
              :disabled="verbatimGeoreferenceAlreadyCreated"
              @click="createVerbatimShape"
              class="button normal-input button-submit">
              Create georeference from verbatim
            </button>
          </div>
          <display-list
            :list="collectingEventId
              ? georeferences
              : queueGeoreferences"
            @delete="removeGeoreference"
            @update="updateRadius"
            @dateChanged="updateDate"
            label="object_tag"/>
        </div>
      </template>
    </modal-component>
  </div>
</template>

<script>

import MapComponent from 'components/georeferences/map'
import SpinnerComponent from 'components/spinner'
import DisplayList from './list'
import convertDMS from 'helpers/parseDMS.js'
import ManuallyComponent from 'components/georeferences/manuallyComponent'
import GeolocateComponent from './geolocate'
import ModalComponent from 'components/ui/Modal'
import extendCE from '../../mixins/extendCE'
import WktComponent from './wkt'
import DateComponent from 'components/ui/Date/DateFields.vue'
import { Georeference } from 'routes/endpoints'
import { truncateDecimal } from 'helpers/math.js'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import { ActionNames } from '../../../store/actions/actions'
import {
  GEOREFERENCE_GEOLOCATE,
  GEOREFERENCE_EXIF,
  GEOREFERENCE_POINT,
  GEOREFERENCE_VERBATIM,
  GEOREFERENCE_WKT,
  GEOREFERENCE_LEAFLET
} from 'constants/index.js'

export default {
  mixins: [extendCE],

  components: {
    MapComponent,
    SpinnerComponent,
    DisplayList,
    ManuallyComponent,
    GeolocateComponent,
    ModalComponent,
    WktComponent,
    DateComponent
  },

  emits: ['onGeoreferences'],

  props: {
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
  },

  computed: {
    georeferenceVerbatimLatitude () {
      return this.verbatimGeoreferenceAlreadyCreated ? truncateDecimal((this.verbatimGeoreferenceAlreadyCreated.geo_json ? this.verbatimGeoreferenceAlreadyCreated.geo_json.geometry.coordinates[1] : JSON.parse(this.verbatimGeoreferenceAlreadyCreated.geographic_item_attributes.shape).geometry.coordinates[1]), 6) : undefined
    },
    georeferenceVerbatimLongitude () {
      return this.verbatimGeoreferenceAlreadyCreated ? truncateDecimal((this.verbatimGeoreferenceAlreadyCreated.geo_json ? this.verbatimGeoreferenceAlreadyCreated.geo_json.geometry.coordinates[0] : JSON.parse(this.verbatimGeoreferenceAlreadyCreated.geographic_item_attributes.shape).geometry.coordinates[0]), 6) : undefined
    },
    georeferenceVerbatimRadiusError () {
      return this.verbatimGeoreferenceAlreadyCreated ? truncateDecimal((this.verbatimGeoreferenceAlreadyCreated.geo_json ? this.verbatimGeoreferenceAlreadyCreated.geo_json.properties.radius : JSON.parse(this.verbatimGeoreferenceAlreadyCreated.geographic_item_attributes.shape).error_radius), 6) : undefined
    },
    verbatimGeoreferenceAlreadyCreated () {
      return [].concat(this.georeferences, this.queueGeoreferences).find(item => item.type === GEOREFERENCE_VERBATIM || item.type === GEOREFERENCE_EXIF)
    },
    mapGeoreferences () {
      return [].concat(this.shapes.features, this.queueGeoreferences.filter(item => (item.type !== GEOREFERENCE_WKT && item.type !== GEOREFERENCE_GEOLOCATE) && item?.geographic_item_attributes?.shape).map(item => JSON.parse(item?.geographic_item_attributes?.shape)))
    },
    geojson () {
      return this.collectingEventId ? this.shapes.features : this.queueGeoreferences
    },
    count () {
      return this.geojson.filter(item => !item?.properties?.geographic_area).length
    },
    verbatimLat () {
      return this.collectingEvent.verbatim_latitude
    },
    verbatimLng () {
      return this.collectingEvent.verbatim_longitude
    },
    geographicArea () {
      return this.$store.getters[GetterNames.GetGeographicArea]?.shape
    },
    GEOREFERENCE_POINT () {
      return GEOREFERENCE_POINT
    },
    georeferences: {
      get () {
        return this.$store.getters[GetterNames.GetGeoreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetGeoreferences, value)
      }
    },
    queueGeoreferences: {
      get () {
        return this.$store.getters[GetterNames.GetQueueGeoreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetQueueGeoreferences, value)
      }
    }
  },

  data () {
    return {
      isProcessing: false,
      showSpinner: false,
      selectedGeoreference: undefined,
      shapes: {
        type: 'FeatureCollection',
        features: []
      },
      date: {
        year_georeferenced: undefined,
        month_georeferenced: undefined,
        day_georeferenced: undefined
      },
      showModal: false
    }
  },

  watch: {
    georeferences: {
      handler () {
        this.populateShapes()
      },
      deep: true
    },

    geographicArea: {
      handler () {
        this.populateShapes()
      },
      deep: true
    }
  },

  methods: {
    updateRadius (geo) {
      const index = geo.id ? this.georeferences.findIndex(item => item.id === geo.id) : this.queueGeoreferences.findIndex(item => item.tmpId === geo.tmpId)

      if (geo.id) {
        this.georeferences[index].error_radius = geo.error_radius
        this.georeferences[index].error_geographic_item_id = geo.geographic_item_id
        this.queueGeoreferences.push(this.georeferences[index])
      } else {
        this.queueGeoreferences[index].error_radius = geo.error_radius
      }
    },

    addGeoreference (shape, type = GEOREFERENCE_LEAFLET) {
      this.queueGeoreferences.push({
        tmpId: Math.random().toString(36).substr(2, 5),
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        error_radius: shape.properties?.radius,
        type,
        ...this.date
      })

      this.$store.dispatch(ActionNames.ProcessGeoreferenceQueue)
    },

    updateGeoreference (shape, type = GEOREFERENCE_LEAFLET) {
      this.addToQueue({
        id: shape.properties.georeference.id,
        error_radius: shape.properties?.radius,
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type
      })

      this.$store.dispatch(ActionNames.ProcessGeoreferenceQueue)
    },

    populateShapes () {
      this.shapes.features = []
      if (this.geographicArea) {
        this.shapes.features.unshift(this.geographicArea)
      }
      this.georeferences.forEach(geo => {
        if (geo.error_radius != null) {
          geo.geo_json.properties.radius = geo.error_radius
        }
        this.shapes.features.push(geo.geo_json)
      })
    },

    removeGeoreference (geo) {
      const index = geo.id ? this.georeferences.findIndex(item => item.id === geo.id) : this.queueGeoreferences.findIndex(item => item.tmpId === geo.tmpId)
      if (geo.id) {
        Georeference.destroy(geo.id).then(() => {
          this.georeferences.splice(index, 1)
          this.$emit('onGeoreferences', this.georeferences)
          this.populateShapes()
        })
      } else {
        this.queueGeoreferences.splice(index, 1)
      }
    },

    createVerbatimShape () {
      const shape = {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'Point',
          coordinates: [convertDMS(this.verbatimLng), convertDMS(this.verbatimLat)]
        }
      }

      this.addToQueue({
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type: GEOREFERENCE_VERBATIM,
        error_radius: this.collectingEvent.verbatim_geolocation_uncertainty
      })

      this.$store.dispatch(ActionNames.ProcessGeoreferenceQueue)
    },

    updateDate (georeference) {
      this.addToQueue(georeference)
      console.log(georeference)
      if (georeference.id) {
        this.$store.dispatch(ActionNames.ProcessGeoreferenceQueue)
      }
    },

    addToQueue (data) {
      this.$store.commit(MutationNames.AddGeoreferenceToQueue, data)
    }
  }
}
</script>
