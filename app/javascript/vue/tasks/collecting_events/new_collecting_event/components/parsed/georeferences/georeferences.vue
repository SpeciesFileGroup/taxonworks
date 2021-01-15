<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = !showModal">Georeference ({{ geojson.length }})</button>
    <button
      v-if="!verbatimGeoreferenceAlreadyCreated"
      type="button"
      class="button normal-input button-submit"
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
      <h3 slot="header">Georeferences</h3>
      <div
        slot="body"
        style="overflow-y: scroll">
        <div class="horizontal-left-content margin-medium-top margin-medium-bottom">
          <wkt-component
            @create="addToQueue"
            class="margin-small-right"/>
          <manually-component
            class="margin-small-right"
            @create="addGeoreference"/>
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
        <div class="horizontal-left-content margin-medium-top margin-medium-bottom">
          <wkt-component
            @create="addToQueue"
            class="margin-small-right"/>
          <manually-component
            class="margin-small-right"
            @create="addGeoreference"/>
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
          v-if="collectingEventId"
          :list="georeferences"
          @delete="removeGeoreference"
          @updateGeo="updateRadius"
          label="object_tag"/>
        <display-list
          v-else
          :list="queueGeoreferences"
          @delete="removeGeoreference"
          @updateGeo="updateRadius"
          label="object_tag"/>
      </div>
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
import AjaxCall from 'helpers/ajaxCall'
import ModalComponent from 'components/modal'
import extendCE from '../../mixins/extendCE'
import WktComponent from './wkt'
import { truncateDecimal } from 'helpers/math.js'

import GeoreferenceTypes from '../../../const/georeferenceTypes'

export default {
  mixins: [extendCE],
  components: {
    MapComponent,
    SpinnerComponent,
    DisplayList,
    ManuallyComponent,
    GeolocateComponent,
    ModalComponent,
    WktComponent
  },
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
      return [].concat(this.georeferences, this.queueGeoreferences).find(item => { return item.type === GeoreferenceTypes.Verbatim || item.type === GeoreferenceTypes.Exif })
    },
    mapGeoreferences () {
      return [].concat(this.shapes.features, this.queueGeoreferences.filter(item => item.type !== GeoreferenceTypes.Wkt && item.type !== GeoreferenceTypes.Geolocate).map(item => JSON.parse(item.geographic_item_attributes.shape)))
    },
    geojson () {
      return this.collectingEventId ? this.shapes.features : this.queueGeoreferences
    },
    verbatimLat () {
      return this.collectingEvent.verbatim_latitude
    },
    verbatimLng () {
      return this.collectingEvent.verbatim_longitude
    },
    geographicArea () {
      return this.collectingEvent.geographicArea?.shape
    },
    georeferences: {
      get () {
        return this.collectingEvent.georeferences
      },
      set (value) {
        this.collectingEvent.georeferences = value
      }
    },
    queueGeoreferences: {
      get () {
        return this.collectingEvent.queueGeoreferences
      },
      set (value) {
        this.collectingEvent.queueGeoreferences = value
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
      showModal: false
    }
  },
  watch: {
    collectingEventId: {
      handler (newVal) {
        if (newVal) {
          this.processQueue().then(() => {
            this.getGeoreferences()
          })
        }
      },
      immediate: true
    },
    queueGeoreferences: {
      handler (newVal) {
        if (newVal.length && this.collectingEventId && this.queueGeoreferences.length) {
          this.processQueue()
        }
      }
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
        this.queueGeoreferences.push(this.georeferences[index])
      } else {
        this.queueGeoreferences[index].error_radius = geo.error_radius
      }
    },
    addGeoreference (shape) {
      this.queueGeoreferences.push({
        tmpId: Math.random().toString(36).substr(2, 5),
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        error_radius: (shape.properties.hasOwnProperty('radius') ? shape.properties.radius : undefined),
        type: GeoreferenceTypes.Leaflet
      })
    },
    processQueue () {
      if (this.isProcessing) return
      return new Promise((resolve, reject) => {
        const promises = []
        this.showSpinner = true
        this.isProcessing = true
        this.queueGeoreferences.forEach(item => {
          item.collecting_event_id = this.collectingEventId
          if (item.id) {
            promises.push(AjaxCall('patch', `/georeferences/${item.id}.json`, { georeference: item }).then(response => {
              const index = this.georeferences.findIndex(geo => { return geo.id === response.body.id })
              this.showSpinner = false
              this.georeferences[index] = response.body
              this.$emit('updated', response.body)
            }, () => {
              this.showSpinner = false
            }))
          } else {
            promises.push(AjaxCall('post', '/georeferences.json', { georeference: item }).then(response => {
              if (response.body.error_radius) {
                response.body.geo_json.properties.radius = response.body.error_radius
              }
              this.georeferences.push(response.body)
              this.$emit('created', response.body)
              this.$emit('onGeoreferences', this.georeferences)
            }, response => {
              this.showSpinner = false
            }))
          }
        })

        Promise.all(promises).then(() => {
          this.showSpinner = false
          this.queueGeoreferences = []
          this.isProcessing = false
          this.populateShapes()
          resolve()
        })
      })
    },
    updateGeoreference (shape) {
      this.queueGeoreferences.push({
        id: shape.properties.georeference.id,
        error_radius: (shape.properties.hasOwnProperty('radius') ? shape.properties.radius : undefined),
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type: GeoreferenceTypes.Leaflet
      })
    },
    getGeoreferences () {
      AjaxCall('get', `/georeferences.json?collecting_event_id=${this.collectingEventId}`).then(response => {
        this.georeferences = response.body
        this.populateShapes()
        this.$emit('onGeoreferences', this.georeferences)
      })
    },
    populateShapes () {
      this.shapes.features = []
      if(this.geographicArea) {
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
        AjaxCall('delete', `/georeferences/${geo.id}.json`).then(() => {
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
      this.queueGeoreferences.push({
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type: GeoreferenceTypes.Verbatim,
        error_radius: this.geolocationUncertainty
      })
    },
    addToQueue (data) {
      this.queueGeoreferences.push(data)
    }
  }
}
</script>
