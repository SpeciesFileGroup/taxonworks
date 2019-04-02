<template>
  <div
    :style="{ width: this.width, height: this.height }"
    ref="leafletMap"
    :id="mapId"/>
</template>

<script>

  import L from 'leaflet'
  import LeafletDraw from 'leaflet-draw'

  delete L.Icon.Default.prototype._getIconUrl

  // L.Icon.Default.mergeOptions({
  //   iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  //   iconUrl: require('leaflet/dist/images/marker-icon.png'),
  //   shadowUrl: require('leaflet/dist/images/marker-shadow.png')
  // })
  var GeoJson;

  L.Icon.Default.mergeOptions({
    iconRetinaUrl: require('./map_icons/mm_20_red.png'),
    iconUrl: require('./map_icons/mm_20_red.png'),
    shadowUrl: require('./map_icons/mm_20_shadow.png')
  });
  export default {
    props: {
      lightThisFeature: {
        // type: Object,
        // default: () => {
        //   return {
        //     collecting_event_id: undefined,
        //     light: false
        //   }
        type: Number,
        default: () => {
          return 0
        }
      },
      width: {
        type: String,
        default: () => {
          return '500px'
        }
      },
      height: {
        type: String,
        default: () => {
          return '500px'
        }
      },
      zoom: {
        type: Number,
        default: () => {
          return 18
        }
      },
      drawControls: {
        type: Boolean,
        default: () => {
          return false
        }
      },
      tilesSelection: {
        type: Boolean,
        default: true
      },
      center: {
        type: Array,
        default: () => {
          return [0, 0]
        }
      },
      geojson: {
        type: Array,
        default: () => {
          return []
        }
      },
    },
    data() {
      return {
        mapId: Math.random().toString(36).substring(7),
        mapObject: undefined,
        drawnItems: undefined,
        foundItems: undefined,
        drawControl: undefined,
        tiles: {
          osm: L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
            maxZoom: 18
          }),
          google: L.tileLayer('http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z}', {
            attribution: 'Google',
            maxZoom: 18
          })
        },
        layers: [],
        highlightRow: undefined,
        restoreRow: undefined,
      }
    },
    watch: {
      geojson: {
        handler(newVal) {
          if (newVal.length) {
            // this.removeLayers()
            this.foundItems.clearLayers();
            this.geoJSON(newVal)
          }
        },
        deep: true
      },
      lightThisFeature(newVal) {
        this.findFeature(newVal)
      },
    },
    mounted() {
      this.mapObject = L.map(this.mapId, {
        center: this.center,
        zoom: this.zoom
      })
      this.drawnItems = new L.FeatureGroup()
      this.foundItems = new L.FeatureGroup()
      this.mapObject.addLayer(this.drawnItems)
      this.mapObject.addLayer(this.foundItems)

      this.addDrawControllers()
      this.handleEvents()
      if (this.geojson.length) {
        this.geoJSON(this.geojson)
      }
    },
    methods: {
      antimeridian(elem, anti) {
        if (Array.isArray(elem)) {
          for (var i = 0; i < elem.length; i++) {
            if (Array.isArray(elem[i][0])) {
              this.antimeridian(elem[i], anti)
            } else {
              if (Array.isArray(elem[i])) {
                if (elem[i][0] < 0) {
                  if (anti) {
                    elem[i][0] = 180 + (180 + elem[i][0])
                  }
                } else {
                  if (!anti && (elem[i][0] > 180)) {
                    elem[i][0] = elem[i][0] - 360
                  }
                }
              } else {
                if (elem[0] < 0) {
                  if (anti) {
                    elem[0] = 180 + (180 + elem[0])
                  }
                } else {
                  if (!anti && (elem[0] > 180)) {
                    elem[0] = elem[0] - 360
                  }
                }
              }
            }
          }
        }
      },
      clearFound() {
        this.foundItems.clearLayers();
      },
      addDrawControllers() {
        if (this.tilesSelection) {
          L.control.layers({
            'OSM': this.tiles.osm.addTo(this.mapObject),
            'Google': this.tiles.google
          }, {'Draw layers': this.drawnItems}, {position: 'topleft', collapsed: false}).addTo(this.mapObject)
        }

        if (this.drawControls) {
          this.mapObject.addControl(new L.Control.Draw({
            edit: {
              featureGroup: this.drawnItems,
              poly: {
                allowIntersection: false
              },
              edit: true
            },
            draw: {
              polygon: {
                allowIntersection: false,
                showArea: true
              }
            }
          }));
          this.mapObject.addControl(this.drawnItems);
          // this.foundItems.addTo(this.mapObject);
        }
      },
      showCoords(layer) {
        let content = layer._latlng.toString() + ' CE_ID:' + layer.feature.properties.collecting_event_id.toString();
        L.popup().setLatLng(event.latlng)
          .setContent(content)
          .openOn(this.mapObject);
      },
      handleEvents() {
        let that = this
        this.mapObject.on(L.Draw.Event.CREATED, function (e) {
          var layer = e.layer;
          var popUp = L.popup();
          var geoJsonLayer = layer.toGeoJSON()
          // if (geoJsonLayer.hasOwnProperty('geometry') && geoJsonLayer.geometry.hasOwnProperty('coordinates')) {
          //   //that.antimeridian(geoJsonLayer.geometry.coordinates, false)
          // }
          if (e.layerType === 'circle') {
            geoJsonLayer.properties.radius = layer.getRadius()
          }
          that.$emit('shapeCreated', layer)
          that.$emit('geoJsonLayerCreated', geoJsonLayer)
          that.drawnItems.addLayer(layer.setStyle({color: "#444400", fillColor: "#888800"}))
        });

        this.mapObject.on('draw:edited', (e) => {
          var layers = e.layers

          that.$emit('shapesEdited', layers)
          that.$emit('geoJsonLayersEdited', that.convertGeoJSONWithPointRadius(layers))
        })
      },
      removeLayers() {
        this.drawnItems.clearLayers()
      },
      convertGeoJSONWithPointRadius(layerArray) {
        let arrayLayers = []

        layerArray.eachLayer(layer => {
          let layerJson = layer.toGeoJSON()
          if (typeof layer.getRadius === 'function') {
            layerJson.properties.radius = layer.getRadius()
          }
          //this.antimeridian(layerJson.geometry.coordinates, false)
          // alert(JSON.stringify(layerJson));
          arrayLayers.push(layerJson)
        })
        return arrayLayers
      },
      toGeoJSON() {
        return this.convertGeoJSONWithPointRadius(this.drawnItems)
      },
      addJsonCircle(layer) {
        L.circle(layer.geometry.coordinates.reverse(), layer.properties.radius).addTo(this.foundItems)
        // L.circle(layer.geometry.coordinates, layer.properties.radius).addTo(this.drawnItems)
      },
      geoJSON(geoJsonFeatures) {
        if (!Array.isArray(geoJsonFeatures) || geoJsonFeatures.length === 0) return
        // this.removeLayers()
        let newGeojson = [];
        geoJsonFeatures.forEach(layer => {   // scan feature array and either (i) or (ii)
          //this.antimeridian(layer.geometry.coordinates, true)
          if (layer.geometry.type === 'Point' && layer.properties.hasOwnProperty('radius')) {
            this.addJsonCircle(layer)       // (i) add a leaflet circle to the drawnItems data element
          } else {
            newGeojson.push(layer)          // (ii) add this feature to the other array
          }
        });

        GeoJson = L.geoJson(newGeojson, {
          style: {
            weight: 1,
            color: '#BB4400',
            dashArray: '',
            fillOpacity: 0.4
          },
          onEachFeature: this.onMyFeatures
        }).addTo(this.foundItems);

          this.mapObject.fitBounds(this.foundItems.getBounds());
         // DON'T rebound the map when just highlighting by either method
      },
      onMyFeatures(feature, layer) {
        if(layer.feature.properties.highlight) {
          this.lightFeature(layer)
        }
        layer.on({
          mouseover: this.highlightFeature,
          mouseout: this.resetHighlight,
          click: this.zoomToFeature
        });
      },
      highlightFeature(e) {
        let layer = e.target;
        this.lightFeature(layer);
        this.$emit("highlightRow", layer.feature.properties.collecting_event_id)
      },
      lightNonPoint(layer) {
        let highlightStyle = {
          weight: 3,
            color: '#909090',
            dashArray: '',
            fillOpacity: 0.7
        };
        if(layer._leaflet_id) {
          GeoJson._layers[layer._leaflet_id].setStyle(highlightStyle);
        }
        else {
          layer.setStyle(highlightStyle);
          layer.addTo(this.foundItems);
        }
      },
      lightFeature(layer) {
        let geom = layer.feature.geometry;
        if (geom.type != "Point") {
          this.lightNonPoint(layer)
        } else {
          if (geom.type == "Point") {
            if (layer.feature.properties["radius"]) {
              this.lightNonPoint(layer)
            } else {
               layer.setIcon(L.icon({
                iconUrl: require('./map_icons/mm_20_blue.png'),
                // iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
                iconRetinaUrl: require('./map_icons/mm_20_blue.png'),
                shadowUrl: require('./map_icons/mm_20_shadow.png'),
                iconSize: [25, 41],
                iconAnchor: [12, 41],
                shadowSize: [41, 41]
                }));
            }
          }
        }
      },
      resetHighlight(e) {   //reversion of working code from01APR2019
        let layer = e.target;
        let geom = layer.feature.geometry;
        if (geom.type == "Point") {
          if (layer.feature.properties["radius"]) {
            GeoJson.resetStyle(layer);
          }
          else {
            layer.setIcon(L.icon({
              iconUrl: require('./map_icons/mm_20_red.png'),
              iconRetinaUrl: require('./map_icons/mm_20_red.png'),
              shadowUrl: require('./map_icons/mm_20_shadow.png')
            }));
          }
        }
        else {
          GeoJson.resetStyle(layer);
        }
        this.$emit("restoreRow", layer.feature.properties.collecting_event_id)
      },
      XresetFeature(e) {
        let layer = e.target;
        this.dimFeature(layer);
        this.$emit("restoreRow", layer.feature.properties.collecting_event_id);
      },
      dimNonPoint(layer) {
        // GeoJson.resetStyle(layer);
        let dimStyle = {
          weight: 1,
          color: '#BB4400',
          dashArray: '',
          fillOpacity: 0.4
        };
        if(layer._leaflet_id) {
          GeoJson._layers[layer._leaflet_id].setStyle(dimStyle);
        }
        else {
          GeoJson.resetStyle(layer);
        }
      },
      dimFeature(layer) {
        let geom = layer.feature.geometry;
        if (geom.type != "Point") {
          this.dimNonPoint(layer)
        } else {
          if (layer.feature.properties["radius"]) {
            GeoJson.resetStyle(layer);
          }
          else {
            layer.setIcon(L.icon({
              iconUrl: require('./map_icons/mm_20_red.png'),
              iconRetinaUrl: require('./map_icons/mm_20_red.png'),
              shadowUrl: require('./map_icons/mm_20_shadow.png')
            }));
          }
        }
      },
      zoomToFeature(e) {
        this.mapObject.fitBounds(e.target.getBounds());
      },
      findFeature(ce_id) {
        // if(ce_id == 0 || ce_id == -0) return
        let layers = GeoJson.getLayers();
        layers.forEach(layer => {
          if(ce_id > 0) {
            if(layer.feature.properties.collecting_event_id == ce_id) {
              this.lightFeature(layer)
            }
          }
          // else {
          //   delete layer.feature.properties.highlight;
            // if(layer.feature.properties.collecting_event_id == -ce_id) {
            //   this.dimFeature(layer)
            // }
          // }
        });
      }
    }
  }
</script>
