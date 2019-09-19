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
        :draw-controls="true"
        :draw-polyline="false"
        :draw-marker="false"
        :drag-mode="false"
        :cut-polygon="false"
        :tiles-selection="false"
        :zoom="1"
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
      geographic_area: undefined
    }
  }
}
</script>
