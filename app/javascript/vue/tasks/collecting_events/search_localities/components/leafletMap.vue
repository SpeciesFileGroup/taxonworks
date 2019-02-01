<template>
  <div id="map" :style="{ height: height, width: width }">
    <l-map style="height: height, width: width" :zoom="zoom" :center="center">
    <l-tile-layer :url="url" :attribution="attribution"></l-tile-layer>
    <l-marker :lat-lng="marker"></l-marker>
    </l-map>
  </div>
</template>

<script>
  import { LMap, LTileLayer, LDraw, LMarker } from 'vue2-leaflet'

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
      LDraw
    },
    props: {
      height: {
        type: [String, Number],
        default: '512px'
      },
      width: {
        type: [String, Number],
        default: '1024px'
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
        center: L.latLng(this.lat, this.lng),
        // url: 'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        url:'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
        attribution:'&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
        marker: L.latLng(this.lat, this.lng),  //L.latLng(0, 0),
        map:  undefined,
        shapes: {},
        // zoom: 12,
      }
    },
    mounted() {
      this.map =  L.map('map', {drawControl: true}).setView(this.center, this.zoom);
      // Initialise the FeatureGroup to store editable layers
      var editableLayers = new L.FeatureGroup();
      this.map.addLayer(editableLayers);

      // var drawPluginOptions = {
      //   position: 'topright',
      //   draw: {
      //     polygon: {
      //       allowIntersection: false, // Restricts shapes to simple polygons
      //       drawError: {
      //         color: '#e1e100', // Color the shape will turn when intersects
      //         message: '<strong>Oh snap!<strong> you can\'t draw that!' // Message that will show when intersect
      //       },
      //       shapeOptions: {
      //         color: '#97009c'
      //       }
      //     },
      //     // disable toolbar item by setting it to false
      //     polyline: true,
      //     circle: false, // Turns off this drawing tool
      //     rectangle: false,
      //     marker: false,
      //   },
      //   edit: {
      //     featureGroup: editableLayers, //REQUIRED!!
      //     remove: false
      //   }
      // };

      // FeatureGroup is to store editable layers
      // var drawnItems = new L.FeatureGroup();
      // this.map.addLayer(drawnItems);
      var drawControl = new L.Control.Draw({
        edit: {
          featureGroup: editableLayers
        }
      });
      map.addControl(drawControl);
    },
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

