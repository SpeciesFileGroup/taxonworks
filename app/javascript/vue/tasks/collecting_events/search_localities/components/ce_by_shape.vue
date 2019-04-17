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
        :light-this-feature="lightMapFeatures"
        :geojson="geojsonFeatures"
        @geoJsonLayerCreated="shapes.push(JSON.stringify($event));"
        @geoJsonLayersEdited="editedShape($event)"
        @shapeCreated="inspectLayer"
        @highlightRow="setHighlight"
        @restoreRow="clearHighlight"
        :draw-controls="true"
      />
      <!--@geoJsonLayerCreated="getShapesData($event)"-->
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
  import Autocomplete from 'components/autocomplete'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'

  export default {
    components: {
      Autocomplete,
      lMap,
      ModeSwitch,
      Spinner,
    },
    props: {
      lightRow: {
        type: Number,
        default: () => {
          return 0
        }
      },
      dimRow: {
        type: Number,
        default: () => {
          return 0
        }
      }
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [],   // intended for eventual multiple shapes paradigm
        mode: 'list',
        isLoading: false,
        newFeatures:  [],
        lightMapFeatures:  0,
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
      lightRow(newVal) {
        this.setHighlightProperty(newVal)
      },
      dimRow(newVal) {
        this.clearHighlightProperty(newVal)
      }
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
        let searchShape = JSON.parse(shapeText);
        let foundEvents = [];
        let params = {shape: shapeText};  // take only last shape pro tem
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          let foundEvents = response.body;
          if(foundEvents.length > 0) {this.collectingEventList = foundEvents;}
          this.$emit('collectingEventList', this.collectingEventList);
          this.isLoading = false;
          // this.getGeoreferences()
        });
        this.$emit("searchShape", JSON.parse(this.shapes[this.shapes.length - 1]))
      },
      editedShape(shape) {
        this.shapes.push(JSON.stringify(shape[0]))
      },
      inspectLayer(layer) {
        // this.clearDrawn = true;
        //////// this.shapes.push(layer.toGeoJSON());
        // this.$emit("searchShape", this.shapes[this.shapes.length - 1])
        // alert (JSON.stringify(geoJ));
      },
      setHighlight(id) {
        this.$emit("highlightRow", id)
      },
      clearHighlight(id) {
        this.$emit("highlightRow", undefined)
      },
      setHighlightProperty(id) {
        // find the right features by collecting_event_id
        this.lightMapFeatures = id;
      },
      clearHighlightProperty(id) {
        // find the right feature by collecting_event_id
        this.geojsonFeatures.forEach((feature, index) => {
          if(feature.properties.collecting_event_id == id) {
            delete(feature.properties.highlight);
            this.$set(this.geojsonFeatures, index, feature)
          }
        });
      },
    },
  }
</script>
