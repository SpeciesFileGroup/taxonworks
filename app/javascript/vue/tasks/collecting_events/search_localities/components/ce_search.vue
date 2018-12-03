<template>
  <div class="find-ce">
    <h3>Find collecting events</h3>
    <div>
      <table>
        <tr v-for="item in geographicAreaList"
        :key="item.id">
        <td><a v-html="item.label_html" @click="showObject()"/></td>
        <td>
          <td><span @click="delistMe(item)">(Remove)</span></td>
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
    <!--<span-->
      <!--v-for="item in geographicAreaList"-->
      <!--:key="item"-->
      <!--v-html="item"/>-->
    <input
      type="button"
      @click="emitCollectingEventData()"
      title="Find">
    <div>
      <span
        v-for="item in collectingEventList"
        :key="item"
        v-html="item.verbatim_locality"/>
      <!--<div>{{ collectingEventList }}</div>-->
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
      emitCollectingEventData(){
        let params = {
          geographic_area_ids: this.geographicAreaList
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
      delistMe(item) {
        this.$delete(this.geographicAreaList, item)
      }
    }
  }
</script>
