<template>
  <div
    class="vue-leaflet"
    :style="{ width: props.width, height: props.height, userSelect: 'none' }"
    ref="leafletMap"
  />
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch, nextTick } from 'vue'
import { Icon } from '@/components/georeferences/icons'
import { DRAW_CONTROLS_MODE, DRAW_CONTROLS_DEFAULT_CONFIG } from './constants'
import geojsonOptions from './utils/geojsonOptions'
import makeGeoJSONObject from './utils/makeGeoJSONObject'
import { getMapTiles } from './utils/getMapTiles'
import { addPatternToMap } from './utils/addPatternToMap.js'
import { setRectangleSelectTool } from './tools/rectangleSelect'
import L from 'leaflet'
import 'leaflet.markercluster/dist/leaflet.markercluster'
import '@geoman-io/leaflet-geoman-free'

const TILE_MAP_STORAGE_KEY = 'tw::map::tile'

let drawnItems
let mapObject
let isShapeToolActive

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
    default: false
  },

  drawMarker: {
    type: Boolean,
    default: false
  },

  drawPolyline: {
    type: Boolean,
    default: false
  },

  drawRectangle: {
    type: Boolean,
    default: false
  },

  drawPolygon: {
    type: Boolean,
    default: false
  },

  drawText: {
    type: Boolean,
    default: false
  },

  editMode: {
    type: Boolean,
    default: false
  },

  dragMode: {
    type: Boolean,
    default: false
  },

  cutPolygon: {
    type: Boolean,
    default: false
  },

  removalMode: {
    type: Boolean,
    default: false
  },

  rotateMode: {
    type: Boolean,
    default: false
  },

  tilesSelector: {
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

  geojsonOptions: {
    type: Function,
    default: geojsonOptions
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

  maxZoom: {
    type: Number,
    default: 18
  },

  minZoom: {
    type: Number,
    default: 0
  },

  actions: {
    type: Boolean,
    default: false
  },

  selection: {
    type: Boolean,
    default: false
  },

  cluster: {
    type: Boolean,
    default: false
  },

  maxClusterRadius: {
    type: Number,
    default: 20
  },

  clusterIconCreateFunction: {
    type: Function,
    default: undefined
  }
})

const emit = defineEmits([
  'draw:start',
  'draw:end',
  'layer:click',
  'layer:dbclick',
  'layer:mouseup',
  'layer:mousedown',
  'layer:mouseover',
  'layer:mouseout',
  'layer:contextmenu',
  'layer:create',
  'layer:edit',
  'layer:remove',
  'layer:update',
  'select',
  'update:geojson'
])

const leafletMap = ref(null)
const tileLayers = getMapTiles()
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
    worldCopyJump: true,
    maxZoom: props.maxZoom
  })

  getDefaultTile().addTo(mapObject)

  mapObject.whenReady(() => addPatternToMap(mapObject.getContainer()))

  drawnItems = props.cluster
    ? new L.markerClusterGroup(makeClusterOptions())
    : new L.FeatureGroup()
  drawnItems.addTo(mapObject)

  if (props.selection) {
    setRectangleSelectTool({
      map: mapObject,
      callback: select,
      layerGroup: drawnItems
    })
  }

  addDrawControllers()
  handleEvents()

  mapObject.pm.setGlobalOptions({
    tooltips: props.tooltips,
    layerGroup: drawnItems,
    markerStyle: { icon: L.divIcon(Icon.Georeference) }
  })

  if (props.geojson.length) {
    geoJSON(props.geojson)
  }
  if (props.resize) {
    initEvents()
  }
})

function resizeMap() {
  mapObject.invalidateSize()

  if (props.fitBounds) {
    centerShapesInMap()
  }
}

function select(layers) {
  const payload = layers.map((layer) => makeLayerPayload(layer))

  emit('select', payload)
}

function initEvents() {
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
  const controls = {
    ...DRAW_CONTROLS_DEFAULT_CONFIG
  }

  DRAW_CONTROLS_MODE.forEach((mode) => {
    controls[mode] = show || props[mode]
  })

  return controls
}

function addEventsToLayer(layer) {
  const makeEventPayload = (event) => ({
    event,
    ...makeLayerPayload(layer)
  })

  layer.on('pm:edit', (event) =>
    emit('layer:edit', makeLayerPayload(event.layer))
  )

  layer.on('click', (event) => emit('layer:click', makeEventPayload(event)))

  layer.on('dbclick', (event) => emit('layer:dbclick', makeEventPayload(event)))

  layer.on('mousedown', (event) =>
    emit('layer:mousedown', makeEventPayload(event))
  )

  layer.on('mouseup', (event) => emit('layer:mouseup', makeEventPayload(event)))

  layer.on('mouseover', (event) =>
    emit('layer:mouseover', makeEventPayload(event))
  )

  layer.on('mouseout', (event) =>
    emit('layer:mouseout', makeEventPayload(event))
  )

  layer.on('contextmenu', (event) =>
    emit('layer:contextmenu', makeEventPayload(event))
  )
}

const addDrawControllers = () => {
  if (props.tilesSelector) {
    L.control
      .layers(tileLayers, {}, { position: 'topleft', collapsed: false })
      .addTo(mapObject)
  }

  mapObject.pm.addControls(getControls(props.drawControls))

  if (!props.actions) {
    mapObject.pm.Toolbar.getControlOrder().forEach((control) => {
      mapObject.pm.Toolbar.changeActionsOfControl(control, [])
    })
  }
}

function makeLayerPayload(layer) {
  const feature = makeGeoJSONObject(layer)

  if (layer instanceof L.Circle) {
    feature.properties.radius = layer.getRadius()
  }

  return { layer, feature }
}

function handleEvents() {
  mapObject.on('baselayerchange', (e) => {
    localStorage.setItem(TILE_MAP_STORAGE_KEY, e.name)
  })

  mapObject.on('pm:create', (e) => {
    emit('layer:create', makeLayerPayload(e.layer))
    emit('update:geojson', drawnItems.toGeoJSON())
  })

  drawnItems.on('pm:update', (e) => {
    emit('layer:update', makeLayerPayload(e.layer))
    emit('update:geojson', drawnItems.toGeoJSON())
  })

  mapObject.on('pm:remove', (e) => {
    emit('layer:remove', makeLayerPayload(e.layer))
    emit('update:geojson', drawnItems.toGeoJSON())
  })

  mapObject.on('pm:globaleditmodetoggled', (e) => {
    isShapeToolActive = e.enabled
  })

  mapObject.on('pm:globaldragmodetoggled', (e) => {
    isShapeToolActive = e.enabled
  })
  mapObject.on('pm:globaldrawmodetoggled', (e) => {
    nextTick(() => {
      isShapeToolActive = e.enabled
    })
  })
}

function getDefaultTile() {
  const defaultTile = localStorage.getItem(TILE_MAP_STORAGE_KEY)

  return tileLayers[defaultTile] || tileLayers.OSM
}

function geoJSON(geoJsonFeatures) {
  if (geoJsonFeatures?.length === 0) {
    mapObject.setView([0, 0], props.zoom)
  } else {
    addGeoJsonLayer(geoJsonFeatures)
  }
}

function addGeoJsonLayer(geoJsonLayers) {
  const geojsonLayer = L.geoJson(
    geoJsonLayers,
    props.geojsonOptions({ L, emit, props })
  )

  geojsonLayer.eachLayer((layer) => {
    addEventsToLayer(layer)
    drawnItems.addLayer(layer)
  })

  if (props.fitBounds && !isShapeToolActive) {
    centerShapesInMap()
  }
}

function centerShapesInMap() {
  const bounds = drawnItems.getBounds()

  nextTick(() => {
    if (Object.keys(bounds).length) {
      mapObject.fitBounds(bounds, fitBoundsOptions.value)
    }
  })
}

function getMapObject() {
  return mapObject
}

function makeClusterOptions() {
  const opt = {
    maxClusterRadius: props.maxClusterRadius
  }

  if (props.clusterIconCreateFunction) {
    Object.assign(opt, {
      iconCreateFunction: (cluster) => {
        return props.clusterIconCreateFunction({ L, cluster })
      }
    })
  }

  return opt
}

defineExpose({
  getMapObject
})
</script>

<style scoped>
.vue-leaflet {
  user-select: none;
  outline-style: none;
}
</style>
