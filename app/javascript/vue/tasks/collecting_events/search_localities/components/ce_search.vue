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
          spatial_geographic_area_ids: geo_ids
        };
        this.$http.get('/collecting_events', {params: params}).then(response => {
          this.collectingEventList = response.body;
        });
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
