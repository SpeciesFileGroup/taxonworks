<template>
  <div
    :style="{ width: this.width, height: this.height }"
    ref="leafletMap"
    :id="mapId"
 />
</template>

<script>

import L from 'leaflet'
import '@geoman-io/leaflet-geoman-free'
import 'leaflet.pattern/src/Pattern'
import 'leaflet.pattern/src/Pattern.SVG'
import 'leaflet.pattern/src/StripePattern'
import 'leaflet.pattern/src/PatternShape'
import 'leaflet.pattern/src/PatternShape.SVG'
import 'leaflet.pattern/src/PatternPath'
import 'leaflet.pattern/src/PatternCircle'

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
    zoomOnClick: {
      type: Boolean,
      default: true
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
      geographicArea: undefined,
      drawControl: undefined,
      tiles: {
        osm: L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
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
        this.geographicArea.clearLayers()
        this.geoJSON(newVal)
      },
      deep: true
    },
    zoom (newVal) {
      this.mapObject.setZoom(newVal)
    }
  },
  mounted () {
    this.mapObject = L.map(this.$el, {
      center: this.center,
      zoom: this.zoom
    })
    this.drawnItems = new L.FeatureGroup()
    this.geographicArea = new L.FeatureGroup()
    this.mapObject.addLayer(this.drawnItems)
    this.mapObject.addLayer(this.geographicArea)

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
    resizeMap (width) {
      const bounds = this.drawnItems.getBounds()

      this.mapSize = width
      this.mapObject.invalidateSize()

      this.$nextTick(() => {
        if (Object.keys(bounds).length && this.fitBounds) {
          this.mapObject.fitBounds(bounds)
        }
      })
    },
    initEvents () {
      this.observeMap = new ResizeObserver(entries => {
        const { width } = entries[0].contentRect

        this.resizeMap(width)
      })
      this.observeMap.observe(this.$el)
    },
    destroyed () {
      this.observeMap.disconnect()
    },
    clearFound () {
      this.drawnItems.clearLayers()
      this.geographicArea.clearLayers()
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
      this.geographicArea.clearLayers()
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
    },
    addGeoJsonLayer (geoJsonLayers) {
      const that = this
      let index = -1

      L.geoJson(geoJsonLayers, {
        style: function (feature) {
          index = index + 1
          return that.randomShapeStyle(index)
        },
        filter: function (feature) {
          if (feature.properties.hasOwnProperty('geographic_area')) {
            that.geographicArea.addLayer(L.GeoJSON.geometryToLayer(feature, Object.assign({}, feature.properties.hasOwnProperty('is_absent') && feature.properties.is_absent ? that.stripeShapeStyle(index) : that.randomShapeStyle(index), { pmIgnore: true })))
            return false
          }
          return true
        },
        onEachFeature: this.onMyFeatures,
        pointToLayer: function (feature, latlng) {
          let shape = (feature.properties.hasOwnProperty('radius') ? that.addJsonCircle(feature) : L.marker(latlng))
          Object.assign(shape, { feature: feature })
          return shape
        }
      }).addTo(this.drawnItems)

      if (this.fitBounds) {
        if (this.getLayersCount(this.drawnItems)) {
          this.mapObject.fitBounds([].concat(this.drawnItems.getBounds()))
        }
        else if (this.geographicArea.getLayers().length) {
          this.mapObject.fitBounds(this.geographicArea.getBounds())
        }
        else {
          this.mapObject.fitBounds([0,0])
        }
      }
    },
    getLayersCount (group) {
      return group.getLayers()[0]._layers ? Object.keys(group.getLayers()[0]._layers).length : undefined
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
      return `hsl(${Math.floor(n * 256)}, ${Math.floor(n * 50) + 100}% , ${(Math.floor((n) + 1) * 60) + 10}%)`
    },
    defaultShapeStyle () {
      return {
        weight: 1,
        dashArray: '',
        fillOpacity: 0.6
      }
    },
    randomShapeStyle (index) {
      return {
        weight: 1,
        color: this.generateHue(index + 6),
        dashArray: '3',
        dashOffset: '3',
        fillOpacity: 0.5
      }
    },
    stripeShapeStyle (index) {
      const color = this.generateHue(index)
      let stripes = new L.StripePattern({
        patternContentUnits: 'objectBoundingBox',
        patternUnits: 'objectBoundingBox',
        weight: 0.05,
        spaceWeight: 0.05,
        height: 0.1,
        angle: 45,
        color: this.generateHue(index + 6),
        opacity: 0.9,
        spaceColor: color,
        spaceOpacity: 0.2
      })
      stripes.addTo(this.mapObject)
      return {
        color: color,
        weight: 2,
        dashArray: '',
        fillOpacity: 1,
        fillPattern: stripes
      }
    },
    onMyFeatures (feature, layer) {
      layer.on({
        'pm:edit': this.editedLayer,
        click: this.zoomToFeature
      })
      if (feature.properties.hasOwnProperty('popup')) {
        layer.bindPopup(feature.properties.popup)
      }
      layer.pm.disable()
    },
    zoomToFeature (e) {
      if (!this.zoomOnClick) return
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
