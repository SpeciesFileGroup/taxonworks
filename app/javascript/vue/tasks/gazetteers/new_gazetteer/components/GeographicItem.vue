<template>
  <VMap
    class="lmap"
    ref="leaflet"
    height="500px"
    width="auto"
    :geojson="shapes"
    fit-bounds
    zoom="1"
    resize
    :draw-controls="drawControls"
    :draw-circle="false"
    :draw-polyline="false"
    :cut-polygon="false"
    :removal-mode="false"
    :edit-mode="false"
    tooltips
    actions
    @geoJsonLayersEdited="(shape) => addToShapes(shape)"
    @geoJsonLayerCreated="(shape) => addToShapes(shape)"
  />

  <DisplayList
    class="geolist"
    :list="shapes"
    @delete="(shape) => removeFromShapes(shape)"
  />
</template>

<script setup>
import DisplayList from './DisplayList.vue'
import VMap from '@/components/georeferences/map'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { ref } from 'vue'

const emit = defineEmits(['shapesUpdated'])

const shapes = ref([])
const drawControls = ref(true)

function addToShapes(shape) {
  if (!shape.uuid) {
    shape.uuid = crypto.randomUUID()
  }

  addToArray(shapes.value, shape, { property: 'uuid' })
  emit('shapesUpdated', shapes)
  drawControls.value = false
}

function removeFromShapes(shape) {
  removeFromArray(shapes.value, shape, { property: 'uuid' })
  drawControls.value = true
}
</script>

<style lang="scss" scoped>
.lmap {
  max-width: 80vw;
  margin: 2em auto;
}

.geolist {
  margin-bottom: 2em;
}
</style>