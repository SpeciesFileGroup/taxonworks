<template>
  <div
    :style="{
      width: width,
      maxHeight: '80vh',
      overflowY: 'scroll'
  }">
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
        :height="height"
        :width="width"
        :geojson="shapes['features']"
        :lat="lat"
        :lng="lng"
        :zoom="zoom"
        :resize="true"
        :draw-controls="true"
        :draw-polyline="false"
        :cut-polygon="false"
        :removal-mode="false"
        @geoJsonLayersEdited="updateGeoreference($event)"
        @geoJsonLayerCreated="saveGeoreference($event)"/>
    </div>
    <button
      type="button"
      v-if="verbatimLat && verbatimLng"
      :disabled="verbatimGeoreferenceAlreadyCreated"
      @click="createVerbatimShape"
      class="button normal-input button-submit separate-bottom separate-top">
      Create georeference from verbatim 
    </button>
    <display-list
      :list="georeferences"
      @delete="removeGeoreference"
      label="object_tag"/>
  </div>
</template>

<script>

import MapComponent from './map'
import SpinnerComponent from 'components/spinner'
import DisplayList from './list'

export default {
  components: {
    MapComponent,
    SpinnerComponent,
    DisplayList
  },
  props: {
    collectingEventId: {
      type: [String, Number],
      required: true,
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
    }
  },
  computed: {
    verbatimGeoreferenceAlreadyCreated () {
      return this.georeferences.find(item => {
        return item.geo_json.geometry.type === 'Point' &&
          Number(item.geo_json.geometry.coordinates[0]) === Number(this.verbatimLng) &&
          Number(item.geo_json.geometry.coordinates[1]) === Number(this.verbatimLat)
      })
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
      }
    }
  },
  mounted () {
    this.getGeoreferences()
  },
  methods: {
    saveGeoreference (shape) {
      const data = {
        georeference: {
          geographic_item_attributes: { shape: JSON.stringify(shape) },
          error_radius: (shape.properties.hasOwnProperty('radius') ? shape.properties.radius : undefined),
          collecting_event_id: this.collectingEventId,
          type: 'Georeference::Leaflet'
        }
      }
      this.showSpinner = true
      this.$http.post('/georeferences.json', data).then(response => {
        this.showSpinner = false
        this.georeferences.push(response.body)
        this.$refs.leaflet.addGeoJsonLayer(response.body.geo_json)
        this.$emit('created', response.body)
        this.$emit('onGeoreferences', this.georeferences)
      }, response => {
        this.showSpinner = false
        TW.workbench.alert.create(response.bodyText, 'error')
      })
    },
    updateGeoreference (shape) {
      const georeference = {
        id: shape.properties.georeference.id,
        error_radius: (shape.properties.hasOwnProperty('radius') ? shape.properties.radius : undefined),
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type: 'Georeference::Leaflet'
      }

      this.showSpinner = true
     
      this.$http.patch(`/georeferences/${georeference.id}.json`, { georeference: georeference }).then(response => {
        const index = this.georeferences.findIndex(geo => { return geo.id == response.body.id })
        this.showSpinner = false
        this.georeferences[index] = response.body
        this.$emit('updated', response.body)
      }, () => {
        this.showSpinner = false
      })
      
    },
    getGeoreferences() {
      this.$http.get(`/georeferences.json?collecting_event_id=${this.collectingEventId}`).then(response => {
        this.georeferences = response.body
        this.populateShapes()
        this.$emit('onGeoreferences', this.georeferences)
      })
    },
    populateShapes() {
      this.shapes.features = []
      this.georeferences.forEach(geo => {
        if (geo.error_radius != null) {
          geo.geo_json.properties.radius = geo.error_radius
        }
        this.shapes.features.push(geo.geo_json)
      })
    },
    removeGeoreference(geo) {
      this.$http.delete(`/georeferences/${geo.id}.json`).then(() => {
        this.georeferences.splice(this.georeferences.findIndex((item => {
          return item.id === geo.id
        })), 1)
        this.$emit('onGeoreferences', this.georeferences)
        this.populateShapes()
      })
    },
    createVerbatimShape() {
      const shape = {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'Point',
          coordinates: [this.verbatimLng, this.verbatimLat]
        }
      }
      const data = {
        georeference: {
          geographic_item_attributes: { shape: JSON.stringify(shape) },
          collecting_event_id: this.collectingEventId,
          type: 'Georeference::VerbatimData'
        }
      }
      this.showSpinner = true
      this.$http.post('/georeferences.json', data).then(response => {
        this.showSpinner = false
        this.georeferences.push(response.body)
        this.populateShapes()
        this.$emit('created', response.body)
      }, response => {
        this.showSpinner = false
        TW.workbench.alert.create(response.bodyText, 'error')
      })
    }
  }
}
</script>
