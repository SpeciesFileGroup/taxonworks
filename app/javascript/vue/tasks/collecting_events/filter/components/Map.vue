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
    georeferences: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    geojson () {
      return this.georeferences.map(item => item.geo_json)
    }
  }

}
</script>
