<template>
  <div>
    <leaflet-map
      :geojson="geojson"
      resize
      width="100%"
      :zoom-bounds="15"
    />
  </div>
</template>

<script>
import LeafletMap from 'components/georeferences/map.vue'

export default {
  components: { LeafletMap },

  props: {
    geojson: {
      type: Array,
      default: () => []
    }
  }
}
</script>
