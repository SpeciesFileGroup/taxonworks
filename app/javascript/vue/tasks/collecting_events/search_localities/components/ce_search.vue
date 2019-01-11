<template>
  <div class="find-ce">
    <h3>Find collecting events by geographic area</h3>
    <div>
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
    </div>
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
    <div>
      <g-map
       :lat="0"
       :lng="0"
       :zoom="1"
       @shape="shapes.push($event)"
      />
    </div>
    <input
      type="button"
      @click="getAreaData()"
      value="Find">
    <div>
      <span v-if="collectingEventList.length" v-html="'<br>' + collectingEventList.length + '  results found.'"/>
      <table>
        <th>Cached</th><th>verbatim locality</th>
        <tr
          v-for="item in collectingEventList"
          :key="item.id">
          <td>
            <span
              v-html="item.id + ' ' + item.cached"
              @click="showObject(item.id)"
            />
          </td>
          <td><span v-html="item.verbatim_locality" /></td>
        </tr>
      </table>
      <input
        type="button"
        @click="getShapesData()"
        value="Find">
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  import gMap from './googleMap.vue'

  export default {
    components: {
      Autocomplete,
      gMap
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [],
      }
    },
  // :height="300"
  // :width="600"
  // :shapes="shapes"
  // :lat="0"
  // :lng="0"
  // :zoom="2"
  // @shape="saveGeoreference($event)"
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
        });
      },
      getShape() {
        this.shapes = this.$event;
      },
      getShapesData(){
        // let geo_ids = [];
        // this.shapes.forEach(area => {
        //   geo_ids.push(area.id)
        // });
        // let params = {
        //   spatial_geographic_area_ids: geo_ids
        // };
        // this.$http.get('/collecting_events', {params: params}).then(response => {
        //   this.collectingEventList = response.body;
        // });
        let params = {shape: this.shapes[this.shapes.length - 1]};
        this.$http.get('/collecting_events.json', {params: params}).then(response => {
          this.collectingEventList = response.body;
        } )
      },
      addGeographicArea(item) {
        this.geographicAreaList.push(item);
      },
        showObject(id) {
            window.open(`/collecting_events/` + id, '_blank');
        },
      delistMe(index) {
        this.$delete(this.geographicAreaList, index)
      }
    }
  }
</script>
