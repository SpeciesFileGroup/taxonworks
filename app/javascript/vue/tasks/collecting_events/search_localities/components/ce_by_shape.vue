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
        width="1024px"
        :zoom="2"
        ref="leaflet"
        :geojson="geojsonFeatures"
        @geoJsonLayerCreated="shapes.push(JSON.stringify($event));"
        @geoJsonLayersEdited="editedShape($event)"
        :draw-controls="true"
      />
      <input
        class="button normal-input button-default separate-left"
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
</template>
<script>
  
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'

  export default {
    components: {
      lMap,
      Spinner,
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [],   // intended for eventual multiple shapes paradigm
        isLoading: false,
        geojsonFeatures: [    // trans-antimeridian polygon test features
        ]
      }
    },
    watch: {
      geojsonFeatures() {
        if(this.geojsonFeatures.length === 0) {
          this.$refs.leaflet.clearFound()
        }
      },
    },
    methods: {
      clearTheMap() {
        this.$refs.leaflet.clearFound()
        this.$refs.leaflet.removeLayers()
        this.geojsonFeatures = [];
      },
      getShapesData(geojsonShape) {
        this.$refs.leaflet.clearFound()
        this.isLoading = true;
        let shapeText = this.shapes[this.shapes.length - 1];
        let params = {shape: shapeText};  // take only last shape pro tem
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          let foundEvents = response.body;
          if(foundEvents.length > 0) {this.collectingEventList = foundEvents;}
          this.$emit('collectingEventList', this.collectingEventList);
          this.isLoading = false;
        });
        this.$emit("searchShape", JSON.parse(this.shapes[this.shapes.length - 1]))
      },
      editedShape(shape) {
        this.shapes.push(JSON.stringify(shape[0]))
      }
    },
  }
</script>
