<template>
  <div class="find-ce">
    <h2>Find collecting events by geographic area</h2>
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
          <td><span @click="delistMe(index)">(Remove)</span></td>
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
        @click="getAreaData()"
        :disabled="!geographicAreaList.length"
        value="Find">
    </div>
    <div v-if="mode==='map'">
      <g-map
       :lat="0"
       :lng="0"
       :zoom="1"
       @shape="shapes.push($event)"
      />
      <input
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
  import AnnotationLogic from 'browse_annotations/components/annotation_logic'
  import ModeSwitch from './mode_switch'

  export default {
    components: {
      Autocomplete,
      gMap,
      AnnotationLogic,
      ModeSwitch,
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [],   // intended for eventual multiple shapes paradigm
        mode: 'list',
        annotation_logic: 'replace',
        // list_or_map: ['list', 'map'],
      }
    },
    methods: {
      getAreaData(){
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
        });
      },
      getShapesData(){
        let params = {shape: this.shapes[this.shapes.length - 1]};  // take only last shape pro tem
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          if(this.annotation_logic == 'append') {
            if(this.collectingEventList.length)
            {this.collectingEventList = this.collectingEventList.concat(response.body);}
            else
            {this.collectingEventList = response.body;}
          }
          else {
            {
              this.collectingEventList = response.body;
            }
          }
          if(this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
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
