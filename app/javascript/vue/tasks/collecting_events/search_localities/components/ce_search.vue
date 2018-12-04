<template>
  <div class="find-ce">
    <h3>Find collecting events</h3>
    <div>
      <table>
        <tr v-for="(item, index) in geographicAreaList"
        :key="item.id">
        <td><a v-html="item.label_html" @click="showObject()"/></td>
        <td>
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
    <input
      type="button"
      @click="getAreaData()"
      value="Find">
    <div>
      <table>
        <tr
          v-for="item in collectingEventList"
          :key="item">
          <td>
            <span
              v-html="item.verbatim_locality"/>
          </td>
        </tr>
      </table>
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'

  export default {
    components: {
      Autocomplete,
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
      }
    },

    methods: {
      getAreaData(){
        let geo_ids = [];
        this.geographicAreaList.forEach(area => {
          geo_ids.push(area.id)
        });
        let params = {
          geographic_area_ids: geo_ids
        };
        this.$http.get('/collecting_events', {params: params}).then(response => {
          this.collectingEventList = response.body.html;
        });
      },
      addGeographicArea(item) {
        this.geographicAreaList.push(item);
      },
      showObject() {
        return true
      },
      delistMe(index) {
        this.$delete(this.geographicAreaList, index)
      }
    }
  }
</script>
