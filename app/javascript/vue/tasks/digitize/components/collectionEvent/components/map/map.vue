<template>
  <div>
    <div style="height: 10%; overflow: auto;">
      Lat: {{ marker.lat }}, Long: {{ marker.lng }}
    </div>
    <l-map style="height: 300px" :zoom="zoom" :center="center">
      <l-tile-layer :url="url" :attribution="attribution"></l-tile-layer>
      <l-marker :lat-lng="marker"></l-marker>
    </l-map>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters.js'
import { LMap, LTileLayer, LMarker } from 'vue2-leaflet'
import 'leaflet/dist/leaflet.css'

export default {
  components: {
    LMap,
    LTileLayer,
    LMarker
  },
  computed: {
    collectionEvent() {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    },
    latitude() {
      return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_latitude
    },
    longitude() {
      return this.$store.getters[GetterNames.GetCollectionEvent].verbatim_longitude
    }
  },
  data () {
    return {
      zoom:13,
      center: L.latLng(0, 0),
      url:'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
      attribution:'&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
      marker: L.latLng(0, 0),
    }
  },
  watch: {
    latitude(newVal) {
      if(!isNaN(newVal) && this.longitude) {
        this.center = L.latLng(newVal, this.longitude)
        this.marker = L.latLng(newVal, this.longitude)
      }
    },
    longitude(newVal) {
      if(!isNaN(newVal) && this.latitude) {
        this.center = L.latLng(this.latitude, newVal)
        this.marker = L.latLng(this.latitude, newVal)
      }
    }
  }
}
</script>
