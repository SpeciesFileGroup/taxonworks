<template>
  <div>
    <h2>Geographic area</h2>
    <switch-component 
      class="separate-bottom"
      v-model="view"
      :options="tabs"/>
    <div v-if="view === 'area'">
      <autocomplete
        url="/geographic_areas/autocomplete"
        label="label"
        placeholder="Search a geographic area"
        param="term"
        @getItem="geographic_area = $event"/>
    </div>
    <div v-else>
      <georeference-map
        width="300px"
        height="300px"
        ref="leaflet"
        :geojson="geojson"
        :draw-controls="true"
        :draw-polyline="false"
        :draw-marker="false"
        :drag-mode="false"
        :cut-polygon="false"
        :draw-circle-marker="false"
        :tiles-selection="false"
        :edit-mode="false"
        :zoom="1"
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
  data () {
    return {
      view: 'area',
      tabs: ['area', 'map'],
      geographic_area: undefined,
      geojson: [],
      shapes: {
        type: "FeatureCollection",
        features: []
      }
    }
  },
  methods: {
    addShape (shape) {
      this.geojson.push(shape)
    }
  }
}
</script>
<style scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%
  }
</style>
