<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h2>Find collecting events by drawn shape</h2>
    <div class="notlongforthisworld">
      <l-map
        height="512px"
        width="100%"
        :zoom="2"
        ref="leaflet"
        :fit-bounds="false"
        @geoJsonLayerCreated="addShape"
        @geoJsonLayersEdited="editedShape"
        :draw-controls="true"
      />
      <div class="separate-top">
        <input
          class="button normal-input button-default"
          type="button"
          @click="getShapesData()"
          :disabled="!shapes.length"
          value="Find">
        <input
          class="button normal-input button-default separate-left"
          type="button"
          @click="clearTheMap"
          value="Clear Search Map">
      </div>
    </div>
  </div>
</template>
<script>
  
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      lMap,
      Spinner,
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [], // intended for eventual multiple shapes paradigm
        isLoading: false
      }
    },
    methods: {
      clearTheMap() {
        this.$refs.leaflet.clearFound()
        this.$refs.leaflet.removeLayers()
        this.shapes = []
      },
      getShapesData(geojsonShape) {
        this.$refs.leaflet.clearFound()
        this.isLoading = true;
        let shapeText = this.shapes[this.shapes.length - 1];
        let params = { geo_json: JSON.stringify({ type: "MultiPolygon", coordinates: [shapeText.geometry.coordinates] })};  // take only last shape pro tem
        AjaxCall('get', '/collecting_events.json', { params: params }).then(response => {
          this.$emit('jsonUrl', response.request.responseURL)
          this.collectingEventList = response.body
          this.$emit('collectingEventList', this.collectingEventList);
          this.isLoading = false;
        });
        this.$emit("searchShape", this.shapes[this.shapes.length - 1])
      },
      editedShape(shape) {
        this.shapes.push(shape)
      },
      addShape(newShapes) {
        this.shapes.push(newShapes)
        this.$refs.leaflet.removeLayers()
      }
    },
  }
</script>
