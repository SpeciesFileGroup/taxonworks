<template>
  <VMap
    class="lmap"
    height="500px"
    width="auto"
    resize
    fit-bounds
    :geojson="shapes"
    :zoom="2"
    :draw-marker="!editingDisabled"
    :draw-rectangle="!editingDisabled"
    :draw-polygon="!editingDisabled"
    :draw-polyline="!editingDisabled"
    :draw-circle="!editingDisabled"
    :drag-mode="!editingDisabled"
    tooltips
    actions
    @layer:create="({ feature }) => emit('shapesUpdated', feature)"
    @layer:edit="({ feature }) => emit('shapesUpdated', feature)"
  />
</template>

<script setup>
import VMap from '@/components/ui/VMap/VMap.vue'

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
