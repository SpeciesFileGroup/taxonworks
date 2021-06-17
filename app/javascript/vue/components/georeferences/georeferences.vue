<template>
  <div
    :style="{
      width: width,
      maxHeight: '80vh',
      overflowY: 'scroll'
  }">
    <div class="horizontal-left-content margin-medium-top margin-medium-bottom">
      <manually-component
        class="margin-small-right"
        @create="saveGeoreference"/>
      <geolocate-component
        class="margin-small-right"
        @create="createGEOLocate"/>
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
        v-if="showSpinner || !collectingEventId"
        :legend="!collectingEventId ? 'Need collecting event ID' : 'Saving...'"/>
      <map-component
        ref="leaflet"
        v-if="show"
        :height="height"
        :width="width"
        :geojson="shapes['features']"
        :lat="lat"
        :lng="lng"
        :zoom="zoom"
        fit-bounds
        resize
        draw-controls
        :draw-polyline="false"
        :cut-polygon="false"
        :removal-mode="false"
        @geoJsonLayersEdited="updateGeoreference($event)"
        @geoJsonLayerCreated="saveGeoreference($event)"/>
    </div>
    <div class="horizontal-left-content margin-medium-top margin-medium-bottom">
      <manually-component
        class="margin-small-right"
        @create="saveGeoreference"/>
      <geolocate-component
        class="margin-small-right"
        @create="createGEOLocate"/>
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
      :list="georeferences"
      @delete="removeGeoreference"
      @updateGeo="updateRadius"
      label="object_tag"/>
  </div>
</template>

<script>

import MapComponent from './map'
import SpinnerComponent from 'components/spinner'
import DisplayList from './list'
import convertDMS from 'helpers/parseDMS.js'
import ManuallyComponent from './manuallyComponent'
import GeolocateComponent from './geolocateComponent'
import { Georeference } from 'routes/endpoints'

export default {
  components: {
    MapComponent,
    SpinnerComponent,
    DisplayList,
    ManuallyComponent,
    GeolocateComponent
  },
  props: {
    collectingEventId: {
      type: [String, Number],
      default: undefined,
    },
    height: {
      type: String,
      default: '500px'
    },
    width: {
      type: String,
      default: 'auto'
    },
    lat: {
      type: Number,
      required: false,
      default: 0
    },
    lng: {
      type: Number,
      required: false,
      default: 0
    },
    geolocationUncertainty: {
      type: [String, Number],
      default: undefined
    },
    verbatimLng: {
      type: [Number, String],
      default: 0
    },
    verbatimLat: {
      type: [Number, String],
      default: 0
    },
    zoom: {
      type: Number,
      default: 1
    },
    show: {
      type: Boolean,
      default: true
    },
    geographicArea: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    verbatimGeoreferenceAlreadyCreated () {
      return this.georeferences.find(item => item.type === 'Georeference::VerbatimData')
    }
  },
  data () {
    return {
      showSpinner: false,
      selectedGeoreference: undefined,
      georeferences: [],
      shapes: {
        type: "FeatureCollection",
        features: []
      },
      creatingShape: false
    }
  },
  watch: {
    collectingEventId: {
      handler (newVal) {
        if (newVal) {
          this.getGeoreferences()
        }
      },
      immediate: true
    },
    show () {
      this.getGeoreferences()
    }
  },
  methods: {
    updateRadius (shape) {
      const georeference = {
        id: shape.id,
        error_radius: shape.error_radius
      }
      this.showSpinner = true

      Georeference.update(shape.id, { georeference }).then(response => {
        this.$emit('updated', response.body)
        this.getGeoreferences()
      }).finally(() => {
        this.showSpinner = false
      })
    },

    saveGeoreference (shape) {
      const georeference = {
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        error_radius: shape.properties?.radius,
        collecting_event_id: this.collectingEventId,
        type: 'Georeference::Leaflet'
      }

      this.showSpinner = true
      Georeference.create({ georeference }).then(response => {
        if (response.body.error_radius) {
          response.body.geo_json.properties.radius = response.body.error_radius
        }
        this.georeferences.push(response.body)
        this.$refs.leaflet.addGeoJsonLayer(response.body.geo_json)
        this.$emit('created', response.body)
        this.$emit('onGeoreferences', this.georeferences)
      }).finally(() => {
        this.showSpinner = false
      })
    },

    updateGeoreference (shape) {
      const georeference = {
        id: shape.properties.georeference.id,
        error_radius: shape.properties?.radius,
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type: 'Georeference::Leaflet'
      }

      this.showSpinner = true
      Georeference.update(georeference.id, { georeference }).then(response => {
        const index = this.georeferences.findIndex(geo => geo.id === response.body.id)

        this.georeferences[index] = response.body
        this.$emit('updated', response.body)
      }).finally(() => {
        this.showSpinner = false
      })
    },

    getGeoreferences() {
      Georeference.where({ collecting_event_id: this.collectingEventId }).then(response => {
        this.georeferences = response.body
        this.populateShapes()
        this.$emit('onGeoreferences', this.georeferences)
      })
    },

    populateShapes() {
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

    removeGeoreference ({ id }) {
      Georeference.destroy(id).then(() => {
        this.georeferences.splice(this.georeferences.findIndex(item => item.id === id), 1)
        this.$emit('onGeoreferences', this.georeferences)
        this.populateShapes()
      })
    },

    createVerbatimShape () {
      if (this.verbatimGeoreferenceAlreadyCreated || this.creatingShape) return
      this.creatingShape = true
      const shape = {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'Point',
          coordinates: [convertDMS(this.verbatimLng), convertDMS(this.verbatimLat)]
        }
      }
      const georeference = {
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type: 'Georeference::VerbatimData',
        error_radius: this.geolocationUncertainty
      }
      this.showSpinner = true

      Georeference.create({ georeference }).then(({ body }) => {
        this.georeferences.push(body)
        this.populateShapes()
        this.$emit('created', body)
        TW.workbench.alert.create('Georeference was successfully created.', 'notice')
      }).finally(() => {
        this.showSpinner = false
        this.creatingShape = false
      })
    },

    createGEOLocate (iframe_data) {
      this.showSpinner = true
      Georeference.create({ 
        georeference: {
          iframe_response: iframe_data,
          collecting_event_id: this.collectingEventId,
          type: 'Georeference::GeoLocate'
        }
      }).then(response => {
        this.georeferences.push(response.body)
        this.populateShapes()
        this.$emit('created', response.body)
      }).finally(() => {
        this.showSpinner = false
      })
    }
  }
}
</script>
