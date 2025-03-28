<template>
  <VMap
    class="lmap"
    ref="leaflet"
    height="500px"
    width="auto"
    :geojson="shapes"
    fit-bounds
    :zoom="1"
    resize
    :draw-controls="!editingDisabled"
    :draw-circle="true"
    :cut-polygon="false"
    :removal-mode="false"
    :edit-mode="false"
    tooltips
    actions
    @geoJsonLayersEdited="(shape) => emit('shapesUpdated', shape)"
    @geoJsonLayerCreated="(shape) => emit('shapesUpdated', shape)"
  />
</template>

<script setup>
import VMap from '@/components/georeferences/map'

const props = defineProps({
  shapes: {
    type: Array,
    default: () => []
  },
  editingDisabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['shapesUpdated'])

</script>

<style lang="scss" scoped>
.lmap {
  max-width: 80vw;
}
</style>