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
    drawCircle: {
      type: Boolean,
      default: true
    },
    drawCircleMarker: {
      type: Boolean,
      default: true
    },
    drawMarker: {
      type: Boolean,
      default: true
    },
    drawPolyline: {
      type: Boolean,
      default: true
    },
    drawRectangle: {
      type: Boolean,
      default: true
    },
    drawPolygon: {
      type: Boolean,
      default: true
    },
    editMode: {
      type: Boolean,
      default: true
    },
    dragMode: {
      type: Boolean,
      default: true
    },
    cutPolygon: {
      type: Boolean,
      default: true
    },
    removalMode: {
      type: Boolean,
      default: true
    },
    tilesSelection: {
      type: Boolean,
      default: true
    },
    tooltips: {
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
    if (this.resize) {
      this.initEvents()
    }
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
      this.tiles.osm.addTo(this.mapObject)
      if (this.tilesSelection) {
        L.control.layers({
          OSM: this.tiles.osm,
          Google: this.tiles.google
        }, { 'Draw layers': this.drawnItems }, { position: 'topleft', collapsed: false }).addTo(this.mapObject)
      }

      if (this.drawControls) {
        this.mapObject.pm.addControls({
          position: 'topleft',
          drawCircle: this.drawCircle,
          drawCircleMarker: this.drawCircleMarker,
          drawMarker: this.drawMarker,
          drawPolyline: this.drawPolyline,
          drawPolygon: this.drawPolygon,
          drawRectangle: this.drawRectangle,
          editMode: this.editMode,
          dragMode: this.dragMode,
          cutPolygon: this.cutPolygon,
          removalMode: this.removalMode
        })
      }

      this.mapObject.pm.enableDraw('Marker', { tooltips: this.tooltips })
      this.mapObject.pm.enableDraw('Polygon', { tooltips: this.tooltips })
      this.mapObject.pm.enableDraw('Circle', { tooltips: this.tooltips })
      this.mapObject.pm.enableDraw('Line', { tooltips: this.tooltips })
      this.mapObject.pm.enableDraw('Rectangle', { tooltips: this.tooltips })
      this.mapObject.pm.enableDraw('Cut', { tooltips: this.tooltips })
      this.mapObject.pm.toggleGlobalDragMode()
    },
    handleEvents () {
      const that = this
      this.mapObject.on('pm:create', (e) => {
        var layer = e.layer
        var geoJsonLayer = this.convertGeoJSONWithPointRadius(layer)

        if (e.layerType === 'circle') {
          geoJsonLayer.properties.radius = layer.getRadius()
        }
        that.$emit('shapeCreated', layer)
        that.$emit('geoJsonLayerCreated', geoJsonLayer)
        that.mapObject.removeLayer(layer)
        that.drawnItems.removeLayer(layer)
      })
      this.mapObject.on('pm:remove', (e) => {
        let geoArray = []
        Object.keys(this.drawnItems.getLayers()[0]._layers).forEach((layerId) => {
          if (Number(layerId) !== Number(e.layer._leaflet_id)) {
            if (this.drawnItems.getLayers()[0]._layers[layerId]) {
              geoArray.push(this.convertGeoJSONWithPointRadius(this.drawnItems.getLayers()[0]._layers[layerId]))
            }
          }
        })
        this.$emit('geojson', geoArray)
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
      return L.circle([layer.geometry.coordinates[1], layer.geometry.coordinates[0]], Number(layer.properties.radius))
    },
    geoJSON (geoJsonFeatures) {
      if (!Array.isArray(geoJsonFeatures) || geoJsonFeatures.length === 0) return

      this.addGeoJsonLayer(geoJsonFeatures)

      if (this.fitBounds) {
        this.mapObject.fitBounds(this.drawnItems.getBounds())
      }
    },
    addGeoJsonLayer (geoJsonLayers) {
      const that = this
      let index = -1
      L.geoJson(geoJsonLayers, {
        style: function (feature) {
          index = index + 1
          return that.randomShapeStyle(index)
        },
        onEachFeature: this.onMyFeatures,
        pointToLayer: function (feature, latlng) {
          let shape = (feature.properties.hasOwnProperty('radius') ? that.addJsonCircle(feature) : L.marker(latlng))
          Object.assign(shape, { feature: feature })
          return shape
        }
      }).addTo(this.drawnItems)
    },
    getRandomColor() {
      const letters = '0123456789ABCDEF'
      let color = '#'
      for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)]
      }
      return color
    },
    generateHue (index) {
      const PHI = (1 + Math.sqrt(5)) / 2
      const n = index * PHI - Math.floor(index * PHI)
      return `hsl(${Math.floor(n * 256)}, ${Math.floor(n * 70) + 40}% , ${(Math.floor((n) + 1) * 60) + 20}%)`
    },
    defaultShapeStyle () {
      return {
        weight: 1,
        dashArray: '',
        fillOpacity: 0.4
      }
    },
    randomShapeStyle (index) {
      return {
        weight: 1,
        color: this.generateHue(index),
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
