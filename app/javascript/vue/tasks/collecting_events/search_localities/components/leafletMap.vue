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

  L.Icon.Default.mergeOptions({
    iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
    iconUrl: require('./map_icons/mm_20_red.png'),
    shadowUrl: require('./map_icons/mm_20_shadow.png')
  })
  export default {
    props: {
      clear: {
        type: Boolean,
        default: () => { return false}
      },
      width: {
        type: String,
        default: () => { return '500px' }
      },
      height: {
        type: String,
        default: () => { return '500px' }
      },
      zoom: {
        type: Number,
        default: () => { return 18 }
      },
      drawControls: {
        type: Boolean,
        default: () => { return false }
      },
      tilesSelection: {
        type: Boolean,
        default: true
      },
      center: {
        type: Array,
        default: () => { return [0, 0] }
      },
      geojson: {
        type: Array,
        default: () => { return [] }
      }
    },
    data () {
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
        layers: []
      }
    },
    watch: {
      geojson (newVal) {
        if (newVal.length) {
          this.geoJSON(newVal)
        }
      },
      clear () {
        this.drawnItems.clearLayers();
        this.foundItems.clearLayers();
      }
    },
    mounted () {
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
      antimeridian (elem, anti) {
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
      addDrawControllers () {
        if (this.tilesSelection) {
          L.control.layers({
            'OSM': this.tiles.osm.addTo(this.mapObject),
            'Google': this.tiles.google
          }, { 'Draw layers': this.drawnItems }, { position: 'topleft', collapsed: false }).addTo(this.mapObject)
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
          }))
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
      handleEvents () {
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
      removeLayers () {
        this.drawnItems.clearLayers()
      },
      convertGeoJSONWithPointRadius (layerArray) {
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
      toGeoJSON () {
        return this.convertGeoJSONWithPointRadius(this.drawnItems)
      },
      addJsonCircle (layer) {
        L.circle(layer.geometry.coordinates.reverse(), layer.properties.radius).addTo(this.foundItems)
        // L.circle(layer.geometry.coordinates, layer.properties.radius).addTo(this.drawnItems)
      },
      geoJSON (geojsonFeature) {
        if (!Array.isArray(geojsonFeature) || geojsonFeature.length === 0) return
        // this.removeLayers()

        let newGeojson = []
        geojsonFeature.forEach(layer => {   // scan feature array and either (i) or (ii)
          //this.antimeridian(layer.geometry.coordinates, true)
          if (layer.geometry.type === 'Point' && layer.properties.hasOwnProperty('radius')) {
            this.addJsonCircle(layer)       // (i) add a leaflet circle to the drawnItems data element
          } else {
            newGeojson.push(layer)          // (ii) add this feature to the other array
          }
        })

        // L.geoJSON(newGeojson).getLayers().forEach(layer => {
        //   this.drawnItems.on('mouseover', this.showCoords);
        //   this.drawnItems.addLayer(layer)
        // });
        let GeoJson = L.geoJson(newGeojson, {
          style: {
            weight: 1,
            color: '#F00',
            dashArray: '',
            fillOpacity: 1.0
          },
          onEachFeature: this.onEachFeature
        }).addTo(this.mapObject);


        this.mapObject.fitBounds(this.drawnItems.getBounds())
      },
      onEachFeature(feature, layer) {
        layer.on({
          mouseover: this.highlightFeature,
          mouseout: this.resetHighlight,
          click: this.zoomToFeature
        });
      },
      highlightFeature(e) {
        var layer = e.target;

        layer.setStyle({
          weight: 5,
          color: '#666',
          dashArray: '',
          fillOpacity: 0.7
        });
      },
      resetHighlight(e) {
        geojson.resetStyle(e.target);
      },
      zoomToFeature(e) {
        this.mapObject.fitBounds(e.target.getBounds());
      }
    }
  }
</script>
