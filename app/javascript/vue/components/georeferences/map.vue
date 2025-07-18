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
import { Icon } from '@/components/georeferences/icons'
import { computed, onMounted, onUnmounted, ref, watch, nextTick } from 'vue'
import { GEOGRAPHIC_AREA } from '@/constants'

let drawnItems
let mapObject
let geographicArea
let drawingLayer = null // layer currently being drawn/created

const TILE_MAP_STORAGE_KEY = 'tw::map::tile'

const DRAW_CONTROLS_PROPS = [
  'drawCircle',
  'drawCircleMarker',
  'drawMarker',
  'drawPolyline',
  'drawPolygon',
  'drawRectangle',
  'drawText',
  'editMode',
  'dragMode',
  'cutPolygon',
  'removalMode',
  'rotateMode'
]

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
    default: 1
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
    default: false
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
  rotateMode: {
    type: Boolean,
    default: false
  },
  tilesSelection: {
    type: Boolean,
    default: true
  },
  tooltips: {
    type: Boolean,
    default: false
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
  },
  actions: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'geoJsonLayerCreated',
  'geoJsonLayersEdited',
  'geojson',
  'shapeCreated',
  'shapesEdited',
  'click:marker'
])

const leafletMap = ref(null)
const tiles = {
  OSM: L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution:
      '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 18,
    className: 'map-tiles'
  }),
  Google: L.tileLayer(
    'http://www.google.cn/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z}',
    {
      attribution: 'Google',
      maxZoom: 18
    }
  ),
  GBIF: L.tileLayer(
    'https://tile.gbif.org/3857/omt/{z}/{x}/{y}@1x.png?style=gbif-natural-en',
    {
      attribution: 'GBIF',
      maxZoom: 18,
      className: 'map-tiles'
    }
  )
}
let observeMap

const fitBoundsOptions = computed(() => ({
  maxZoom: props.zoomBounds,
  zoom: {
    animate: props.zoomAnimate
  }
}))

watch(
  () => props.geojson,
  (newVal) => {
    drawnItems.clearLayers()
    geographicArea.clearLayers()
    geoJSON(newVal)
  },
  { deep: true }
)

watch(
  () => props.zoom,
  (newVal) => {
    mapObject.setZoom(newVal)
  }
)

watch(
  () => props.drawControls,
  (newVal) => {
    mapObject.pm.addControls(getControls(newVal))
  }
)

onMounted(() => {
  mapObject = L.map(leafletMap.value, {
    center: props.center,
    zoom: props.zoom,
    worldCopyJump: true
  })

  drawnItems = new L.FeatureGroup()
  geographicArea = new L.FeatureGroup()
  mapObject.addLayer(drawnItems)
  mapObject.addLayer(geographicArea)

  addDrawControllers()
  handleEvents()

  mapObject.pm.setGlobalOptions({
    tooltips: props.tooltips,
    markerStyle: { icon: L.divIcon(Icon.Georeference) }
  })

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
  observeMap = new ResizeObserver((entries) => {
    const { width } = entries[0].contentRect

    resizeMap(width)
  })

  observeMap.observe(leafletMap.value)
}

onUnmounted(() => {
  observeMap?.disconnect()
})

function getControls(show) {
  let controls = { position: 'topleft' }
  DRAW_CONTROLS_PROPS.forEach((prop) => {
    controls[prop] = show ? props[prop] : false
  })

  return controls
}

const addDrawControllers = () => {
  getDefaultTile().addTo(mapObject)
  if (props.tilesSelection) {
    L.control
      .layers(tiles, {}, { position: 'topleft', collapsed: false })
      .addTo(mapObject)
  }

  if (props.drawControls) {
    mapObject.pm.addControls(getControls(true))
  }

  if (!props.actions) {
    mapObject.pm.Toolbar.getControlOrder().forEach((control) => {
      mapObject.pm.Toolbar.changeActionsOfControl(control, [])
    })
  }
}

const handleEvents = () => {
  mapObject.on('baselayerchange', (e) => {
    localStorage.setItem(TILE_MAP_STORAGE_KEY, e.name)
  })

  mapObject.on('pm:create', (e) => {
    drawingLayer = null
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

  mapObject.on('pm:remove', (e) => {
    const geoArray = []
    const layers = Object.keys(drawnItems.getLayers()[0]._layers)

    layers.forEach((layerId) => {
      if (Number(layerId) !== Number(e.layer._leaflet_id)) {
        if (drawnItems.getLayers()[0]._layers[layerId]) {
          geoArray.push(
            convertGeoJSONWithPointRadius(
              drawnItems.getLayers()[0]._layers[layerId]
            )
          )
        }
      }
    })
    emit('geojson', geoArray)
  })

  mapObject.on('pm:drawstart', (e) => {
    drawingLayer = e.workingLayer
  })

  mapObject.on('pm:drawend', (e) => {
    drawingLayer = null
  })
}

function getDefaultTile() {
  const defaultTile = localStorage.getItem(TILE_MAP_STORAGE_KEY)

  return tiles[defaultTile] || tiles.OSM
}

const editedLayer = (e) => {
  const layer = e.target

  emit('shapesEdited', layer)
  emit('geoJsonLayersEdited', convertGeoJSONWithPointRadius(layer))
}

const convertGeoJSONWithPointRadius = (layer) => {
  const layerJson = layer.toGeoJSON()

  if (typeof layer.getRadius === 'function') {
    layerJson.properties.radius = layer.getRadius()
  }

  return layerJson
}

const addJsonCircle = (layer) => {
  return L.circle(
    [layer.geometry.coordinates[1], layer.geometry.coordinates[0]],
    Number(layer.properties.radius)
  )
}

const geoJSON = (geoJsonFeatures) => {
  if (geoJsonFeatures?.length === 0) {
    mapObject.setView([0, 0], props.zoom)
  } else {
    addGeoJsonLayer(geoJsonFeatures)
  }
}

const addGeoJsonLayer = (geoJsonLayers) => {
  let index = -1

  L.geoJson(geoJsonLayers, {
    style: (feature) => {
      index = index + 1
      return {
        ...randomShapeStyle(index),
        ...feature.properties?.style
      }
    },
    filter: (feature) => {
      if (
        feature.properties?.aggregate ||
        feature.properties?.shape?.type === GEOGRAPHIC_AREA
      ) {
        geographicArea.addLayer(
          L.GeoJSON.geometryToLayer(
            feature,
            Object.assign(
              {},
              feature.properties?.is_absent
                ? stripeShapeStyle(-1)
                : randomShapeStyle(-1),
              { ...feature.properties?.style },
              { pmIgnore: true }
            )
          )
        )
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
  const icon = L.divIcon(
    Icon[feature?.properties?.marker?.icon] || Icon.Georeference
  )
  const marker = L.marker(latlng, { icon })

  marker.on('click', (event) => emit('click:marker', event))

  return marker
}

const generateHue = (index) => {
  const PHI = (1 + Math.sqrt(5)) / 2
  const n = index * PHI - Math.floor(index * PHI)

  return `hsl(${Math.floor(n * 256)}, ${Math.floor(n * 50) + 100}% , ${
    Math.floor(n + 1) * 60 + 10
  }%)`
}

const randomShapeStyle = (index) => ({
  weight: 2,
  color: generateHue(index + 6),
  dashArray: '3',
  dashOffset: '3',
  fillOpacity: 0.25
})

const stripeShapeStyle = (index) => {
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

const zoomToFeature = (e) => {
  if (!props.zoomOnClick) return
  const layer = e.target
  if (props.fitBounds && !drawingLayer) {
    if (layer instanceof L.Marker || layer instanceof L.Circle) {
      mapObject.fitBounds([layer.getLatLng()], fitBoundsOptions.value)
    } else {
      mapObject.fitBounds(e.target.getBounds(), fitBoundsOptions.value)
    }
  }
}

function getMapObject() {
  return mapObject
}

defineExpose({
  getMapObject
})
</script>
