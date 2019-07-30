<template>
  <div
    :style="{ width: this.width, height: this.height }"
    ref="leafletMap"
    :id="mapId"
 />
</template>

<script>

import L from 'leaflet'
import 'leaflet.pm'

delete L.Icon.Default.prototype._getIconUrl

L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png')
})

export default {
  props: {
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
    resize: {
      type: Boolean,
      default: false
    },
    geojson: {
      type: Array,
      default: () => {
        return []
      }
    },
    fitBounds: {
      type: Boolean,
      default: true
    }
  },
  data () {
    return {
      mapSize: undefined,
      observeMap: undefined,
      mapId: Math.random().toString(36).substring(7),
      mapObject: undefined,
      drawnItems: undefined,
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
      restoreRow: undefined
    }
  },
  watch: {
    geojson: {
      handler (newVal) { 
        this.drawnItems.clearLayers()
        this.geoJSON(newVal)
      },
      deep: true
    },
    zoom (newVal) {
      this.mapObject.setZoom(newVal)
    }
  },
  mounted () {
    this.mapObject = L.map(this.mapId, {
      center: this.center,
      zoom: this.zoom
    })
    this.drawnItems = new L.FeatureGroup()
    this.mapObject.addLayer(this.drawnItems)

    this.addDrawControllers()
    this.handleEvents()
    if (this.geojson.length) {
      this.geoJSON(this.geojson)
    }
    if (this.resize)
      {this.initEvents()}
  },
  methods: {
    resizeMap (mutationsList, observer) {
      if (this.$el.clientWidth != this.mapSize) {
        this.$nextTick(() => {
          this.mapSize = this.$el.clientWidth
          const bounds = this.drawnItems.getBounds()
          if (Object.keys(bounds).length) {
            if (this.fitBounds) {
              this.mapObject.fitBounds(bounds)
            }
          }
          this.mapObject.invalidateSize()
        })
      }
    },
    initEvents () {
      this.mapSize = this.$el.clientWidth
      this.observeMap = new MutationObserver(this.resizeMap)
      this.observeMap.observe(this.$el, { attributes: true, childList: true, subtree: true })
    },
    destroyed () {
      this.observeMap.disconnect()
    },
    clearFound () {
      this.drawnItems.clearLayers()
    },
    addDrawControllers () {
      if (this.tilesSelection) {
        L.control.layers({
          OSM: this.tiles.osm.addTo(this.mapObject),
          Google: this.tiles.google
        }, { 'Draw layers': this.drawnItems }, { position: 'topleft', collapsed: false }).addTo(this.mapObject)
      }

      if (this.drawControls) {
        this.mapObject.pm.addControls({
          position: 'topleft'
        })
      }
    },
    handleEvents () {
      const that = this
      this.mapObject.on('pm:create', (e) => {
        var layer = e.layer
        var geoJsonLayer = layer.toGeoJSON()

        if (e.layerType === 'circle') {
          geoJsonLayer.properties.radius = layer.getRadius()
        }
        that.$emit('shapeCreated', layer)
        that.$emit('geoJsonLayerCreated', geoJsonLayer)
        that.drawnItems.addLayer(layer.setStyle({ color: '#444400', fillColor: '#888800' }))
      })
    },
    removeLayers () {
      this.drawnItems.clearLayers()
    },
    editedLayer (e) {
      var layer = e.target

      this.$emit('shapesEdited', layer)
      this.$emit('geoJsonLayersEdited', this.convertGeoJSONWithPointRadius(layer))
    },
    convertGeoJSONWithPointRadius (layer) {
      const layerJson = layer.toGeoJSON()

      if (typeof layer.getRadius === 'function') {
        layerJson.properties.radius = layer.getRadius()
      }

      return layerJson
    },
    addJsonCircle (layer) {
      const circle = L.circle([...layer.geometry.coordinates].reverse(), layer.properties.radius)
      circle.setStyle(this.defaultShapeStyle())
      circle.on('pm:edit', e => this.editedLayer(e))
      circle.addTo(this.drawnItems)
    },
    geoJSON (geoJsonFeatures) {
      if (!Array.isArray(geoJsonFeatures) || geoJsonFeatures.length === 0) return
      const newGeojson = []
      geoJsonFeatures.forEach(layer => { // scan feature array and either (i) or (ii)
        if (layer.geometry.type === 'Point' && layer.properties.hasOwnProperty('radius')) {
          this.addJsonCircle(layer) // (i) add a leaflet circle to the drawnItems data element
        } else {
          newGeojson.push(layer) // (ii) add this feature to the other array
        }
      })

      L.geoJson(newGeojson, {
        style: this.defaultShapeStyle(),
        onEachFeature: this.onMyFeatures
      }).addTo(this.drawnItems)
      
      if (this.fitBounds) {
        this.mapObject.fitBounds(this.drawnItems.getBounds())
      }
    },
    defaultShapeStyle () {
      return {
        weight: 1,
        color: '#BB4400',
        dashArray: '',
        fillOpacity: 0.4
      }
    },
    onMyFeatures (feature, layer) {
      layer.on({
        'pm:edit': this.editedLayer,
        click: this.zoomToFeature
      })
    },
    zoomToFeature (e) {
      const layer = e.target
      if (this.fitBounds) {
        if (layer instanceof L.Marker || layer instanceof L.Circle) {
          this.mapObject.fitBounds([layer.getLatLng()])
        } else {
          this.mapObject.fitBounds(e.target.getBounds())
        }
      }
    }
  }
}
</script>
