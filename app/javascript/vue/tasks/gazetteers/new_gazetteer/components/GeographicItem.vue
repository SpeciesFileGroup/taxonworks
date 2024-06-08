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
    :draw-controls="true"
    :draw-polyline="false"
    :cut-polygon="false"
    :removal-mode="false"
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

function addToShapes(shape) {
  if (!shape.uuid) {
    shape.uuid = crypto.randomUUID()
  }

  addToArray(shapes.value, shape, { property: 'uuid' })
  emit('shapesUpdated', shapes)
}

function removeFromShapes(shape) {
  removeFromArray(shapes.value, shape, { property: 'uuid' })
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