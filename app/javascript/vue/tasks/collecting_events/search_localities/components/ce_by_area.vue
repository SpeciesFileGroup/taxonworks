<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <h2>Find collecting events by named geographic area</h2>
    <div>
      <table>
        <tr
          v-for="(item, index) in geographicAreaList"
          :key="item.id">
          <td>
            <span v-html="item.label_html"/>
          </td>
          <td>
            <span
              class="remove_area"
              data-icon="trash"
              @click="deListArea(index)"
            />
          </td>
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
        class="button normal-input button-default"
        @click="getAreaData()"
        :disabled="!geographicAreaList.length"
        value="Find">
    </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  import Spinner from 'components/spinner'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      Autocomplete,
      Spinner,
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        isLoading: false
      }
    },
    methods: {
      getAreaData() {
        this.isLoading = true;
        let geo_ids = this.geographicAreaList.map(area => { return area.id })
        let params = {
          geographic_area_ids: geo_ids,
          spatial_geographic_areas: true
        }

        AjaxCall('get', '/collecting_events.json', { params: params }).then(response => {
          this.collectingEventList = response.body;
          this.$emit('jsonUrl', response.request.responseURL)
          if (this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          this.isLoading = false
        });
      },
      addGeographicArea(item) {
        this.geographicAreaList.push(item);
      },
      deListArea(index) {
        this.$delete(this.geographicAreaList, index)
      },
    },
  }
</script>
