<template>
  <VMap
    height="500px"
    width="100%"
    :geojson="store.shapes"
    fit-bounds
    resize
    draw-controls
    :draw-polyline="false"
    :cut-polygon="false"
    tooltips
    actions
  />
</template>

<script setup>
import useStore from '../store/store'
import VMap from '@/components/ui/VMap/VMap.vue'

const store = useStore()
</script>
