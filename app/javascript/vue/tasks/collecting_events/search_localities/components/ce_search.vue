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
              @click="showObject()"/>
          </td>
          <td><span class="remove_area" data-icon="trash" @click="delistMe(index)"/></td>
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
        type="button" class="button normal-input button-default separate-left"
        @click="getAreaData()"
        :disabled="!geographicAreaList.length"
        value="Find">
    </div>
    <div v-if="mode==='map'">
      <l-map
        height="512px"
        width="1024px"
        :zoom="2"
        ref="leaflet"
        :light-this-feature="lightMapFeature"
        :geojson="geojsonFeatures"
        @geoJsonLayerCreated="shapes.push(JSON.stringify($event));"
        @geoJsonLayersEdited="editedShape($event)"
        @shapeCreated="inspectLayer"
        @highlightRow="setHighlight"
        @restoreRow="clearHighlight"
        :draw-controls="true"
        :dont-rescale="dontRescale"
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
        value="Clear Map">
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  import lMap from './leafletMap.vue'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'

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
        dontRescale:  false,
        lightMapFeature:  0,
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
      getAreaData() {
        this.isLoading = true;
        let geo_ids = [];
        this.geographicAreaList.forEach(area => {
          geo_ids.push(area.id)
        });
        let params = {
          spatial_geographic_area_ids: geo_ids
        };
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
          if (this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          this.isLoading = false;
        });
      },
      getShapesData(geojsonShape) {
        this.dontRescale = false;
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
          let ce_ids = [];      // find the georeferences for these collecting_events
          this.collectingEventList.forEach(ce => {
            ce_ids.push(ce.id)
          });
          if (ce_ids.length) {                // if the list has contents
            let cycles = (ce_ids.length / 30);  // each item is about 30 characters, make each cycle less than 2000 chars
            let FeatureCollection = {
              "type": "FeatureCollection",
              "features": []
            };
            let that = this;
            let thisSlice = 0;
            let endSlice;
            let finalSlice = ce_ids.length;
            let newFeatures = [];
            this.newFeatures = [];
            let promises = [];
            for (let i = 0; i < cycles; i++) {
              endSlice = thisSlice + 30;
              if ((thisSlice + 30) > finalSlice) {
                endSlice = finalSlice + 1
              }
              params = {
                collecting_event_ids: ce_ids.slice(thisSlice, endSlice)
              };
              promises.push(this.makePromise(params));
              thisSlice += 30;
            }
            Promise.all(promises).then(featuresArrays => {
              // if (searchShape) {FeatureCollection.features.push(searchShape)}
              featuresArrays.forEach(f => {FeatureCollection.features = FeatureCollection.features.concat(f)});
              that.geojsonFeatures = that.geojsonFeatures.concat(FeatureCollection.features);
              this.$emit('featuresList', this.geojsonFeatures);
            });
            this.isLoading = false;
          }
          else {
            this.isLoading = false;
          }
        })
      },
      makePromise(params) {
        return new Promise((resolve, reject) => {
          this.$http.get('/georeferences.json', {params: params}).then(response => {
            // put these geometries on the map as features
            let newFeatures = response.body.map(georeference => {
              georeference.geo_json.properties["collecting_event_id"] = georeference.collecting_event_id;
              return georeference.geo_json
            });
           resolve(newFeatures);    // resolves to array of features
          })
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
        // this.clearDrawn = true;
        this.shapes.push(layer.toGeoJSON());
        // alert (JSON.stringify(geoJ));
      },
      setHighlight(id) {
        this.$emit("highlightRow", id)
      },
      clearHighlight(id) {
        this.$emit("highlightRow", undefined)
      },
      // setHighlightProperty(id) {
      //   // find the right feature by collecting_event_id
      //   this.dontRescale = true;
      //   this.geojsonFeatures.forEach((feature,index) => {
      //     if(feature.properties.collecting_event_id == id) {
      //       feature.properties.highlight = id
      //       this.$set(this.geojsonFeatures, index, feature)
      //     }
      //   });
      //   // this.dontRescale = false;
      // },
      setHighlightProperty(id) {
        // find the right feature by collecting_event_id
        this.lightMapFeature = id;
      },
      clearHighlightProperty(id) {
        // find the right feature by collecting_event_id
        this.dontRescale = true;
        this.geojsonFeatures.forEach((feature, index) => {
          if(feature.properties.collecting_event_id == id) {
            delete(feature.properties.highlight);
            this.$set(this.geojsonFeatures, index, feature)
          }
        });
        // this.dontRescale = false;
      },
    },
  }
</script>
