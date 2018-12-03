<template>
  <div class="find-ce">
    <h3>Find collecting events</h3>
    <autocomplete
      class="separate-bottom"
      url="/geographic_areas/autocomplete"
      min="2"
      ref="autocomplete"
      param="term"
      placeholder="Select a named geographic area"
      label="label_html"
      @getItem="sendGeographicArea($event)"
      :autofocus="true"
      :clear-after="true"/>
    <input
      type="button"
      @click="emitGeographicAreaData()"
      title="Find">
    <div>
      <span
        v-for="item in geographicAreaList"
        :key="item"
        v-html="item.name"/>
      <div>{{ geographicAreaList }}</div>
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
        geographicAreaList: []
      }
    },

    methods: {
      emitGeographicAreaData(){
        let params = {
          geographic_area_ids: this.geographicAreaList
        };
        this.$http.get('/collecting_events', {params: params}).then(response => {
          this.geographicAreaList = response.body.html;
        });
      },
      sendGeographicAres(item) {
        this.selected = '';
        this.$emit('select', item.id)
      },
    }
  }
</script>
