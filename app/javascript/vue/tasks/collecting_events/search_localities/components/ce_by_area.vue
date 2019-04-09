<template>
  <div class="find-ce">
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h2>Find collecting events by named geographic area</h2>
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
          <td><span class="remove_area" data-icon="trash" @click="deListArea(index)"/></td>
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
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  import ModeSwitch from './mode_switch'
  import Spinner from 'components/spinner'
  import lMap from './leafletMap.vue'

  export default {
    components: {
      Autocomplete,
      lMap,
      ModeSwitch,
      Spinner,
    },
    props: {
      lightRow: {
        type: Number,
        default: () => {
          return 0
        }
      },
      dimRow: {
        type: Number,
        default: () => {
          return 0
        }
      }
    },
    data() {
      return {
        geographicAreaList: [],
        collectingEventList: [],
        shapes: [],   // intended for eventual multiple shapes paradigm
        mode: 'list',
        isLoading: false,
        newFeatures:  [],
        lightMapFeatures:  0,
        geojsonFeatures: [    // trans-antimeridian polygon test features
        ]
      }
    },
    watch: {
      geojsonFeatures() {
        if(this.geojsonFeatures.length === 0) {
          this.$refs.leaflet.clearFound()
        }
      },
      lightRow(newVal) {
        this.setHighlightProperty(newVal)
      },
      dimRow(newVal) {
        this.clearHighlightProperty(newVal)
      }
    },
    methods: {
      clearTheMap() {
        this.$refs.leaflet.clearFound()
        this.$refs.leaflet.removeLayers()
        this.geojsonFeatures = [];
      },
      getAreaData() {
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
          if (this.collectingEventList) {
            this.$emit('collectingEventList', this.collectingEventList)
          }
          // this.getGeoreferences();
          this.isLoading = false;
        });
      },
      addGeographicArea(item) {
        this.geographicAreaList.push(item);
      },
      deListArea(index) {
        this.$delete(this.geographicAreaList, index)
      },
      editedShape(shape) {
        this.shapes.push(JSON.stringify(shape[0]))
      },
      inspectLayer(layer) {
        // this.clearDrawn = true;
        this.shapes.push(layer.toGeoJSON());
        // alert (JSON.stringify(geoJ));
      },
      setHighlight(id) {
        this.$emit("highlightRow", id)
      },
      clearHighlight(id) {
        this.$emit("highlightRow", undefined)
      },
      setHighlightProperty(id) {
        // find the right features by collecting_event_id
        this.lightMapFeatures = id;
      },
      clearHighlightProperty(id) {
        // find the right feature by collecting_event_id
        this.geojsonFeatures.forEach((feature, index) => {
          if(feature.properties.collecting_event_id == id) {
            delete(feature.properties.highlight);
            this.$set(this.geojsonFeatures, index, feature)
          }
        });
      },
    },
  }
</script>
