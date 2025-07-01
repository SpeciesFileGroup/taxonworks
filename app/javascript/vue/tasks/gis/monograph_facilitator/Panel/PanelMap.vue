<template>
  <VMap
    height="100%"
    width="100%"
    :geojson="store.shapes"
    fit-bounds
    resize
    draw-controls
    :draw-polyline="false"
    :cut-polygon="false"
    tooltips
    actions
    @select="setSelectedObjects"
  />
</template>

<script setup>
import VMap from '@/components/ui/VMap/VMap.vue'
import useStore from '../store/store.js'

const store = useStore()

function setSelectedObjects(arr) {
  const features = arr.map((item) => item.feature)
  console.log(arr, features)
  const objects = features
    .map((f) => store.getObjectByGeoreferenceId(f.properties.georeference.id))
    .flat()
  const ids = objects.map((o) => o.objectId)

  store.selectedIds = [...new Set(ids)]
}
</script>
