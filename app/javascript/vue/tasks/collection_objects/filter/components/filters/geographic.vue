<template>
  <div>
    <h2>Geographic area</h2>
    <switch-component 
      class="separate-bottom"
      v-model="view"
      :options="tabs"/>
    <div v-if="view === 'area'">
      <div class="field">
        <autocomplete
          url="/geographic_areas/autocomplete"
          label="label"
          :clear-after="true"
          placeholder="Search a geographic area"
          param="term"
          @getItem="addGeoArea"/>
      </div>
      <label>
        <input 
          v-model="geographic.spatial_geographic_areas"
          type="checkbox"/>
        Treat geographic areas as spatial
      </label>
      <div class="field separate-top">
        <ul class="no_bullets table-entrys-list">
          <li
            class="middle flex-separate list-complete-item"
            v-for="(geoArea, index) in geographic_areas"
            :key="geoArea.id">
            <span v-html="geoArea.label"/>
            <span
              class="btn-delete button-circle"
              @click="removeGeoArea(index)"/>
          </li>
        </ul>
      </div>
    </div>
    <div v-else>
      <georeference-map
        width="330px"
        height="300px"
        ref="leaflet"
        :geojson="geojson"
        @geojson="geojson = $event"
        :draw-controls="true"
        :draw-polyline="false"
        :draw-marker="false"
        :drag-mode="false"
        :cut-polygon="false"
        :draw-circle-marker="false"
        :tiles-selection="false"
        :edit-mode="false"
        :zoom="1"
        :tooltips="false"
        @geoJsonLayerCreated="addShape"
      />
    </div>
  </div>
</template>

<script>

import SwitchComponent from 'components/switch'
import Autocomplete from 'components/autocomplete'
import GeoreferenceMap from 'components/georeferences/map'

export default {
  components: {
    SwitchComponent,
    Autocomplete,
    GeoreferenceMap
  },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    geographic: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      view: 'area',
      tabs: ['area', 'map'],
      geographic_areas: [],
      geojson: []
    }
  },
  watch: {
    geojson: {
      handler (newVal) {
        this.geographic.geojson = JSON.stringify({ type: "MultiPolygon", coordinates: newVal.map(feature => { return feature.geometry.coordinates }) })
      },
      deep: true
    }
  },
  methods: {
    addShape (shape) {
      this.geojson.push(shape)
    },
    removeGeoArea (index) {
      this.geographic.geographic_area_ids.splice(index, 1)
      this.geographic_areas.splice(index, 1)
    },
    addGeoArea (item) {
      this.geographic.geographic_area_ids.push(item.id)
      this.geographic_areas.push(item)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
