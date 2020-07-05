<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h2>Find collecting events by geographic area or shape</h2>
    <mode-switch v-model="mode"/>
    <div v-if="mode==='list'">
      <table>
        <tr
          v-for="(item, index) in geographicAreaList"
          :key="item.id">
          <td>
            <a
              v-html="item.label_html"
              @click="showObject()"
            />
          </td>
          <td>
            <span
              class="remove_area"
              data-icon="trash"
              @click="delistMe(index)"
            />
          </td>
        </tr>
      </table>
      <autocomplete
        class="separate-bottom"
        url="/geographic_areas/autocomplete"
        min="2"
        ref="autocomplete"
        param="term"
        placeholder="Select a named geographic area"
        label="label_html"
        @getItem="addGeographicArea($event)"
        :autofocus="true"
        :clear-after="true"
      />
      <input
        type="button"
        class="button normal-input button-default separate-left"
        @click="getAreaData()"
        :disabled="!geographicAreaList.length"
        value="Find">
    </div>
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
        value="Clear Map">
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'
  import AjaxCall from 'helpers/ajaxCall'

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
        geojsonFeatures: []    // trans-antimeridian polygon test features
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
      getAreaData() {
        this.isLoading = true;
        let geo_ids = this.geographicAreaList.map(area => { return area.id })
        let params = {
          'geographic_area_ids[]': geo_ids,
          spatial_geographic_areas: true
        }
        
        AjaxCall('get', '/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
          this.$emit('jsonUrl', response.request.responseURL)
          if (this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          this.isLoading = false;
        });
      },
      getShapesData(geojsonShape) {
        this.$refs.leaflet.clearFound()
        this.isLoading = true;
        let shapeText = this.shapes[this.shapes.length - 1];
        let params = {shape: shapeText};  // take only last shape pro tem
        AjaxCall('get', '/collecting_events.json', {params: params}).then(response => {
          let foundEvents = response.body;
          this.$emit('jsonUrl', response.request.responseURL)
          if(foundEvents.length > 0) {this.collectingEventList = foundEvents;}
          this.$emit('collectingEventList', this.collectingEventList);
          this.isLoading = false;
        })
      },
      addGeographicArea(item) {
        this.geographicAreaList.push(item);
      },
      delistMe(index) {
        this.$delete(this.geographicAreaList, index)
      },
      editedShape(shape) {
        this.shapes.push(JSON.stringify(shape[0]))
      },
      inspectLayer(layer) {
        this.shapes.push(layer.toGeoJSON());
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
