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
    :draw-controls="!editingDisabled"
    :draw-circle="false"
    :cut-polygon="false"
    :removal-mode="false"
    :edit-mode="false"
    tooltips
    actions
    @geoJsonLayersEdited="(shape) => addToShapes(shape)"
    @geoJsonLayerCreated="(shape) => addToShapes(shape)"
  />
</template>

<script setup>
import VMap from '@/components/georeferences/map'
import { addToArray } from '@/helpers/arrays'

const props = defineProps({
  shapes: {
    type: Array,
    default: []
  },
  editingDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['shapesUpdated'])

function addToShapes(shape) {
  emit('shapesUpdated', shape)
}
</script>

<style lang="scss" scoped>
.lmap {
  max-width: 80vw;
  margin: 0px auto 2em auto;
}
</style>