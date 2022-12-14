<template>
  <div
    :style="{ width: props.width, height: props.height }"
    ref="leafletMap"
  />
</template>

<script setup>

import L from 'leaflet'
import '@geoman-io/leaflet-geoman-free'
import 'leaflet.pattern/src/Pattern'
import 'leaflet.pattern/src/Pattern.SVG'
import 'leaflet.pattern/src/StripePattern'
import 'leaflet.pattern/src/PatternShape'
import 'leaflet.pattern/src/PatternShape.SVG'
import 'leaflet.pattern/src/PatternPath'
import 'leaflet.pattern/src/PatternCircle'
import iconRetina from 'leaflet/dist/images/marker-icon-2x.png'
import iconUrl from 'leaflet/dist/images/marker-icon.png'
import shadowUrl from 'leaflet/dist/images/marker-shadow.png'
import { Icon } from 'components/georeferences/icons'
import { computed, onMounted, onUnmounted, ref, watch, nextTick } from 'vue'

delete L.Icon.Default.prototype._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: iconRetina,
  iconUrl,
  shadowUrl
})

let drawnItems
let mapObject
let geographicArea

const props = defineProps({
  zoomAnimate: {
    type: Boolean,
    default: false
  },
  width: {
    type: String,
    default: '500px'
  },
  height: {
    type: String,
    default: '500px'
  },
  zoom: {
    type: Number,
    default: 18
  },
  drawControls: {
    type: Boolean,
    default: false
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
  drawText: {
    type: Boolean,
    default: false
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
    default: () => [0, 0]
  },
  resize: {
    type: Boolean,
    default: false
  },
  geojson: {
    type: Array,
    default: () => []
  },
  zoomOnClick: {
    type: Boolean,
    default: true
  },
  fitBounds: {
    type: Boolean,
    default: true
  },
  zoomBounds: {
    type: Number,
    default: undefined
  }
})

const emit = defineEmits([
  'geoJsonLayerCreated',
  'geoJsonLayersEdited',
  'geojson',
  'shapeCreated',
  'shapesEdited'
])

const leafletMap = ref(null)
const tiles = {
  osm: L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 18
  }),
  google: L.tileLayer('http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z}', {
    attribution: 'Google',
    maxZoom: 18
  })
}
let observeMap

const fitBoundsOptions = computed(() =>
  ({
    maxZoom: props.zoomBounds,
    zoom: {
      animate: props.zoomAnimate
    }
  })
)

watch(() => props.geojson, newVal => {
  drawnItems.clearLayers()
  geographicArea.clearLayers()
  geoJSON(newVal)
}, { deep: true })

watch(() => props.zoom, newVal => { mapObject.setZoom(newVal) })

onMounted(() => {
  mapObject = L.map(leafletMap.value, {
    center: props.center,
    zoom: props.zoom
  })

  drawnItems = new L.FeatureGroup()
  geographicArea = new L.FeatureGroup()
  mapObject.addLayer(drawnItems)
  mapObject.addLayer(geographicArea)

  addDrawControllers()
  handleEvents()

  if (props.geojson.length) {
    geoJSON(props.geojson)
  }
  if (props.resize) {
    initEvents()
  }
})

const resizeMap = () => {
  mapObject.invalidateSize()

  if (props.fitBounds) {
    centerShapesInMap()
  }
}

const initEvents = () => {
  observeMap = new ResizeObserver(entries => {
    const { width } = entries[0].contentRect

    resizeMap(width)
  })

  observeMap.observe(leafletMap.value)
}

onUnmounted(() => {
  observeMap?.disconnect()
})

const addDrawControllers = () => {
  tiles.osm.addTo(mapObject)
  if (props.tilesSelection) {
    L.control.layers({
      OSM: tiles.osm,
      Google: tiles.google
    }, { 'Draw layers': drawnItems }, { position: 'topleft', collapsed: false }).addTo(mapObject)
  }

  if (props.drawControls) {
    mapObject.pm.addControls({
      position: 'topleft',
      drawCircle: props.drawCircle,
      drawCircleMarker: props.drawCircleMarker,
      drawMarker: props.drawMarker,
      drawPolyline: props.drawPolyline,
      drawPolygon: props.drawPolygon,
      drawRectangle: props.drawRectangle,
      drawText: props.drawText,
      editMode: props.editMode,
      dragMode: props.dragMode,
      cutPolygon: props.cutPolygon,
      removalMode: props.removalMode
    })
  }
}
const handleEvents = () => {
  mapObject.on('pm:create', e => {
    const layer = e.layer
    const geoJsonLayer = convertGeoJSONWithPointRadius(layer)

    if (e.layerType === 'circle') {
      geoJsonLayer.properties.radius = layer.getRadius()
    }

    emit('shapeCreated', layer)
    emit('geoJsonLayerCreated', geoJsonLayer)
    mapObject.removeLayer(layer)
    drawnItems.removeLayer(layer)
  })

  mapObject.on('pm:remove', e => {
    const geoArray = []
    const layers = Object.keys(drawnItems.getLayers()[0]._layers)

    layers.forEach(layerId => {
      if (Number(layerId) !== Number(e.layer._leaflet_id)) {
        if (drawnItems.getLayers()[0]._layers[layerId]) {
          geoArray.push(convertGeoJSONWithPointRadius(drawnItems.getLayers()[0]._layers[layerId]))
        }
      }
    })
    emit('geojson', geoArray)
  })
}

const editedLayer = e => {
  const layer = e.target

  emit('shapesEdited', layer)
  emit('geoJsonLayersEdited', convertGeoJSONWithPointRadius(layer))
}

const convertGeoJSONWithPointRadius = layer => {
  const layerJson = layer.toGeoJSON()

  if (typeof layer.getRadius === 'function') {
    layerJson.properties.radius = layer.getRadius()
  }

  return layerJson
}

const addJsonCircle = layer => {
  return L.circle([layer.geometry.coordinates[1], layer.geometry.coordinates[0]], Number(layer.properties.radius))
}

const geoJSON = geoJsonFeatures => {
  if (!Array.isArray(geoJsonFeatures) || geoJsonFeatures.length === 0) return
  addGeoJsonLayer(geoJsonFeatures)
}

const addGeoJsonLayer = geoJsonLayers => {
  let index = -1

  L.geoJson(geoJsonLayers, {
    style: (_) => {
      index = index + 1
      return randomShapeStyle(index)
    },
    filter: feature => {
      if (feature.properties?.geographic_area) {
        geographicArea.addLayer(L.GeoJSON.geometryToLayer(feature, Object.assign({}, feature.properties?.is_absent ? stripeShapeStyle(index) : randomShapeStyle(index), { pmIgnore: true })))
        return false
      }
      return true
    },

    onEachFeature: onMyFeatures,
    pointToLayer: (feature, latlng) => {
      const shape = feature.properties?.radius
        ? addJsonCircle(feature)
        : createMarker(feature, latlng)

      Object.assign(shape, { feature })

      return shape
    }
  }).addTo(drawnItems)

  if (props.fitBounds) {
    centerShapesInMap()
  }
}

const centerShapesInMap = () => {
  const bounds = drawnItems.getBounds()

  bounds.extend(geographicArea.getBounds())

  nextTick(() => {
    if (Object.keys(bounds).length) {
      mapObject.fitBounds(bounds, fitBoundsOptions.value)
    }
  })
}

const createMarker = (feature, latlng) => {
  const icon = Icon[feature?.properties?.marker?.icon] || Icon.blue
  const marker = L.marker(latlng, { icon })

  return marker
}

const generateHue = index => {
  const PHI = (1 + Math.sqrt(5)) / 2
  const n = index * PHI - Math.floor(index * PHI)

  return `hsl(${Math.floor(n * 256)}, ${Math.floor(n * 50) + 100}% , ${(Math.floor((n) + 1) * 60) + 10}%)`
}

const randomShapeStyle = index => ({
  weight: 1,
  color: generateHue(index + 6),
  dashArray: '3',
  dashOffset: '3',
  fillOpacity: 0.5
})

const stripeShapeStyle = index => {
  const color = generateHue(index)
  const stripes = new L.StripePattern({
    patternContentUnits: 'objectBoundingBox',
    patternUnits: 'objectBoundingBox',
    weight: 0.05,
    spaceWeight: 0.05,
    height: 0.1,
    angle: 45,
    color: generateHue(index + 6),
    opacity: 0.9,
    spaceColor: color,
    spaceOpacity: 0.2
  })

  stripes.addTo(mapObject)

  return {
    color,
    weight: 2,
    dashArray: '',
    fillOpacity: 1,
    fillPattern: stripes
  }
}

const onMyFeatures = (feature, layer) => {
  layer.on({
    'pm:edit': editedLayer,
    click: zoomToFeature
  })
  if (feature.properties?.popup) {
    layer.bindPopup(feature.properties.popup)
  }
  layer.pm.disable()
}

const zoomToFeature = e => {
  if (!props.zoomOnClick) return
  const layer = e.target
  if (props.fitBounds) {
    if (layer instanceof L.Marker || layer instanceof L.Circle) {
      mapObject.fitBounds([layer.getLatLng()], fitBoundsOptions.value)
    } else {
      mapObject.fitBounds(e.target.getBounds(), fitBoundsOptions.value)
    }
  }
}

</script>
