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
        :geojson="geojsonFeature"
        @geoJsonLayerCreated="shapes.push(JSON.stringify($event));"
        :draw-controls="true"
      />
      <!--@geoJsonLayerCreated="getShapesData($event)"-->
      <input class="button normal-input button-default separate-left"
        type="button"
        @click="getShapesData()"
        :disabled="!shapes.length"
        value="Find">
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  // import gMap from './googleMap.vue'
  // import lMap from './leafletMap.vue'
  import lMap from 'components/leaflet/map.vue'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'

  export default {
    components: {
      Autocomplete,
      // gMap,
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
        geojsonFeature: [
          {
            'type': 'Feature',
            'properties': {},
            'geometry': {
              'type': 'Point',
              'coordinates': [-59.816437, -27.446959]
            },
          },
          {
          'type': 'Feature',
          'properties': {
            'radius': 108575.53450828836
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [-59.341021, -34.231603, ]
          }
        },
        {
          'type': 'Feature',
          'properties': {
            'radius': 108575.53450828836
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [-59.816437, -28.446959, ]
          }
        }
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
      // getShapesData(){
      //   this.isLoading = true;
      //   let params = {shape: this.shapes[this.shapes.length - 1]};  // take only last shape pro tem
      //   this.$http.get('/collecting_events.json', {params: params}).then(response => {
      //     this.collectingEventList = response.body;
      //     if(this.collectingEventList) {
      //       this.$emit('collectingEventList', this.collectingEventList)
      //     }
      //     this.isLoading = false;
      //   } )
      // },
      getShapesData(geojsonShape){
        this.isLoading = true;
        // let geoString = JSON.stringify(geojsonShape);
        // this.$http.get('/collecting_events.json', { params: {shape: geoString} }).then(response => {
        let params = {shape: this.shapes[this.shapes.length - 1]};  // take only last shape pro tem
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
          if(this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
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
    // addGeographicArea(item) {
    //     this.geographicAreaList.push(item);
    //   },
    //   delistMe(index) {
    //     this.$delete(this.geographicAreaList, index)
    //   }
    // }
  }
</script>
