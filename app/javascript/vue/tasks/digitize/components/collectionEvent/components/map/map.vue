<template>
  <div v-if="latitude && longitude">
    <div style="height: 10%; overflow: auto;">
      Map verification
    </div>
    <l-map style="height: 300px; width:100%" :zoom="zoom" :center="center">
      <l-tile-layer :url="url" :attribution="attribution"></l-tile-layer>
      <l-marker :lat-lng="marker"></l-marker>
    </l-map>
  </div>
  <div
    v-else
    class="panel aligner"
    style="height: 300px; align-items: center; width:310px">
    <h3>Fill lat/long to display the map</h3>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters.js'
import { LMap, LTileLayer, LMarker } from 'vue2-leaflet'
import Spinner from 'components/spinner'

delete L.Icon.Default.prototype._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});

export default {
  components: {
    LMap,
    LTileLayer,
    LMarker,
    Spinner
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
<style scoped>
.aligner {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
