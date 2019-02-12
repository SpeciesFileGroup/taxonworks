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
        :geojson="geojsonFeatures"
        @geoJsonLayerCreated="shapes.push(JSON.stringify($event));"
        :draw-controls="true"
      />
      <!--@geoJsonLayerCreated="getShapesData($event)"-->
      <input
        class="button normal-input button-default separate-left"
        type="button"
        @click="getShapesData()"
        :disabled="!shapes.length"
        value="Find">
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  import lMap from 'components/leaflet/map.vue'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'

  export default {
    components: {
      Autocomplete,
      lMap,
      ModeSwitch,
      Spinner,
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [],   // intended for eventual multiple shapes paradigm
        mode: 'list',
        isLoading: false,
        geojsonFeatures: [
          {"type":"Feature",
            "geometry":{"type":"Point","coordinates":[-116.848889,33.478056,1066.8]},
            "properties":{"georeference":{"id":5,"tag":"Georeference ID = 5"}}},
          {"type":"Feature","geometry":{"type":"Point","coordinates":[-154,69,0]},"properties":{"georeference":{"id":42477,"tag":"Georeference ID = 42477"}}},
          {"type":"Feature","geometry":{"type":"Point","coordinates":[-158.32,68.246,0]},"properties":{"georeference":{"id":95395,"tag":"Georeference ID = 95395"}}},
          {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-128.67480397224426,70.99598264111805,0],[162.59472727775574,68.69703692453726,0],[-125.68652272224426,62.48255407659341,0],[-128.67480397224426,70.99598264111805,0]]]},"properties":{"georeference":{"id":127782,"tag":"Georeference ID = 127782"}}},
          {"type":"Feature","geometry":{"type":"Point","coordinates":[-103.43093455511473,38.50019222109752,0]},"properties":{"georeference":{"id":127831,"tag":"Georeference ID = 127831"}}}
        ]
      }
    },
    methods: {
      getAreaData(){
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
          if(this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          this.isLoading = false;
        });
      },
      getShapesData(geojsonShape){
        this.isLoading = true;
        let params = {shape: this.shapes[this.shapes.length - 1]};  // take only last shape pro tem
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
          if(this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          let ce_ids = [];      // find the georeferences for these collecting_events
          this.collectingEventList.forEach(ce => {
            ce_ids.push(ce.id)
          });
          params = {
            collecting_event_ids: ce_ids
          };
          if(ce_ids.length) {
            this.$http.get('/georeferences.json', {params:params}).then(response => {
              let FeatureCollection = {
                "type": "FeatureCollection",
                "features": []
              };
              // put thiese geometries on the map as features
              FeatureCollection.features = response.body.map(georeference => {
                return georeference.geo_json
              });
              this.geojsonFeatures = FeatureCollection.features;    //since we currently require an array of features
            });
          }
          this.isLoading = false;
        } )
      },
      addGeographicArea(item) {
        this.geographicAreaList.push(item);
      },
      delistMe(index) {
        this.$delete(this.geographicAreaList, index)
      }
    },
  }
</script>
