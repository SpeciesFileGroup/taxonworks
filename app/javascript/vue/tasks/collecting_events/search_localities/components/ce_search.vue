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
      <g-map
       :lat="0"
       :lng="0"
       :zoom="2"
       @shape="shapes.push($event)"
      />
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
  import gMap from './googleMap.vue'
  // import leafMap from './leafletMap.vue'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'

  export default {
    components: {
      Autocomplete,
      gMap,
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
      getShapesData(){
        this.isLoading = true;
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
    }
  }
</script>
