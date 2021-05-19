<template>
  <leaflet-map
    :geojson="geojson"
    resize
    width="100%"
    fit-bounds
  />
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
