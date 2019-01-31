<template>
  <div id="map" :style="{ height: height, width: width }">
    <l-map style="height: height, width: width" :zoom="zoom" :center="center">
    <l-tile-layer :url="url" :attribution="attribution"></l-tile-layer>
    <l-marker :lat-lng="marker"></l-marker>
    </l-map>
  </div>
</template>

<script>
  import { LMap, LTileLayer, LMarker } from 'vue2-leaflet'

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
    props: {
      height: {
        type: [String, Number],
        default: '512px'
      },
      width: {
        type: [String, Number],
        default: '512px'
      },
      lat: {
        type: Number,
        required: false,
        default: 0
      },
      lng: {
        type: Number,
        required: false,
        default: 0
      },
      zoom: {
        type: Number,
        default: 12
      },
      // shapes: {
      //   type: Object,
      //   default: () => { return {} }
      // },
    },
    data() {
      return {
        center: L.latLng(-41.2858, 174.78682),
        // url: 'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        url:'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
        attribution:'&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
        marker: L.latLng(-41.2858, 174.78682),  //L.latLng(0, 0),
        map:  undefined,
        shapes: {},
        // zoom: 12,
      }
    },
    // mounted() {
    //   map = L.map("map").setView([37.75, -122.23], 10);
    //
    //   L.esri.basemapLayer("Topographic").addTo(map);
    // }
    //   var map = L.map('map').setView([-41.2858, 174.78682], 14);
    //   mapLink =
    //     '<a href="http://www.esri.com/">Esri</a>';
    //   wholink =
    //     'i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';
    //   L.tileLayer(
    //     'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
    //       attribution: '&copy; '+mapLink+', '+wholink,
    //       maxZoom: 18,
    //     }).addTo(map);
    //
    // }
  }
</script>
<!--<style lang="sass">-->
  <!--@import "../../node_modules/leaflet/dist/leaflet.css"-->
  <!--@import "../../node_modules/leaflet.markercluster/dist/MarkerCluster.css"-->
  <!--#map-->
    <!--width: 100%-->
    <!--height: 400px-->
    <!--font-weight: bold-->
    <!--font-size: 13px-->
    <!--text-shadow: 0 0 2px #fff-->
    <!--.leaflet-shadow-pane > .leaflet-marker-shadow-->
      <!--display: none-->
<!--</style>-->

