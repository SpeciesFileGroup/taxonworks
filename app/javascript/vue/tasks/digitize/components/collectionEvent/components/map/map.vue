<template>
  <div>
    <template v-if="collectionEvent.verbatim_latitude && collectionEvent.verbatim_longitude">
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
        class="panel aligner middle"
        style="height: 300px; align-items: center; width:310px; text-align: center;">
        <h3>Verbatim latitude/longitude unparsable or incomplete, location preview unavailable.' (perhaps with warning triangle).</h3>
      </div>
    </template>
    <div
      v-else
      class="panel aligner"
      style="height: 300px; align-items: center; width:310px; text-align: center;">
      <h3>Provide verbatim latitude/longitude to preview location on map.</h3>
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../../../../store/getters/getters.js'
import { LMap, LTileLayer, LMarker } from 'vue2-leaflet'
import convertDMS from '../../../../helpers/parseDMS.js'

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
    LMarker
  },
  computed: {
    collectionEvent() {
      return this.$store.getters[GetterNames.GetCollectionEvent]
    },
    latitude() {
      return convertDMS(this.$store.getters[GetterNames.GetCollectionEvent].verbatim_latitude)
    },
    longitude() {
      return convertDMS(this.$store.getters[GetterNames.GetCollectionEvent].verbatim_longitude)
    }
  },
  data () {
    return {
      zoom:8,
      center: L.latLng(0, 0),
      url:'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
      attribution:'&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
      marker: L.latLng(0, 0),
    }
  },
  watch: {
    latitude(newVal) {
      if(newVal && this.longitude) {
        this.center = L.latLng(newVal, this.longitude)
        this.marker = L.latLng(newVal, this.longitude)
      }
    },
    longitude(newVal) {
      if(newVal && this.latitude) {
        this.center = L.latLng(this.latitude, newVal)
        this.marker = L.latLng(this.latitude, newVal)
      }
    }
  },
  methods: {
    convertDMS(value) {
      try {
        return parseDMS(value)
      }
      catch(error) {
        return undefined
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
