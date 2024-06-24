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

  <DisplayList
    class="geolist"
    :list="shapes"
    @delete="(shape) => removeFromShapes(shape)"
    :editingDisabled="editingDisabled"
  />
</template>

<script setup>
import DisplayList from './DisplayList.vue'
import VMap from '@/components/georeferences/map'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { ref } from 'vue'

const props = defineProps({
  editingDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['shapesUpdated'])

const shapes = ref([])

function addToShapes(shape) {
  if (!shape.uuid) {
    shape.uuid = crypto.randomUUID()
  }

  addToArray(shapes.value, shape, { property: 'uuid' })
  emit('shapesUpdated', shapes.value)
}

function removeFromShapes(shape) {
  removeFromArray(shapes.value, shape, { property: 'uuid' })
}
</script>

<style lang="scss" scoped>
.lmap {
  max-width: 80vw;
  margin: 0px auto 2em auto;
}

.geolist {
  margin-bottom: 2em;
}
</style>