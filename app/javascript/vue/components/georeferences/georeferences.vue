<template>
  <div
    :style="{
      width: width
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
        :height="height"
        :width="width"
        :geojson="shapes['features']"
        :lat="lat"
        :lng="lng"
        :zoom="zoom"
        :resize="true"
        :draw-controls="true"
        @geoJsonLayersEdited="updateGeoreference($event)"
        @geoJsonLayerCreated="saveGeoreference($event)"/>
    </div>
    <display-list
      :list="georeferences"
      @delete="removeGeoreference"
      label="object_tag"/>
  </div>
</template>

<script>

import MapComponent from './map'
import SpinnerComponent from 'components/spinner'
import DisplayList from 'components/displayList'

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
    zoom: {
      type: Number,
      default: 1
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
          collecting_event_id: this.collectingEventId,
          type: 'Georeference::GoogleMap'
        }
      }
      this.showSpinner = true
      this.$http.post('/georeferences.json', data).then(response => {
        this.showSpinner = false
        this.georeferences.push(response.body)
        this.populateShapes()
        this.$emit('created', response.body)
      })
    },
    updateGeoreference (shape) {
      let georeference = {
        id: shape.properties.georeference.id,
        geographic_item_attributes: { shape: JSON.stringify(shape) },
        collecting_event_id: this.collectingEventId,
        type: 'Georeference::GoogleMap'
      }

      this.showSpinner = true
     
      this.$http.patch(`/georeferences/${georeference.id}.json`, { georeference: georeference }).then(response => {
        this.showSpinner = false
        let index = this.georeferences.findIndex(geo => { return geo.id == response.body.id })
        this.georeferences[index] = response.body
        this.shapes = []
        this.populateShapes()
        this.$emit('updated', response.body)
      }, () => {
        this.showSpinner = false
      })
      
    },
    getGeoreferences() {
      this.$http.get(`/georeferences.json?collecting_event_id=${this.collectingEventId}`).then(response => {
        this.georeferences = response.body
        this.populateShapes()
      })
    },
    populateShapes() {
      this.shapes.features = []
      this.georeferences.forEach(geo => {
        this.shapes.features.push(geo.geo_json)
      })
    },
    removeGeoreference(geo) {
      this.$http.delete(`/georeferences/${geo.id}.json`).then(() => {
        this.georeferences.splice(this.georeferences.findIndex((item => {
          return item.id == geo.id
        })), 1)
        this.populateShapes()
      })
    }
  }
}
</script>
