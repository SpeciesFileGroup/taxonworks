<template>
  <VMap
    height="100%"
    width="100%"
    :geojson="store.shapes"
    fit-bounds
    resize
    tooltips
    @select="setSelectedObjects"
  />
</template>

<script setup>
import VMap from '@/components/ui/VMap/VMap.vue'
import useStore from '../store/store.js'
import { usePressedKey } from '@/composables/usePressedKey.js'

const store = useStore()
const { isKeyPressed } = usePressedKey()

function setSelectedObjects(arr) {
  const features = arr.map((item) => item.feature)
  const objects = features
    .map((f) => store.getObjectByGeoreferenceId(f.properties.georeference.id))
    .flat()
  const ids = objects.map((o) => o.objectId)

  if (isKeyPressed('Control')) {
    ids.push(...store.selectedIds)
  }

  store.selectedIds = [...new Set(ids)]
}
</script>

<style>
@keyframes pulse-marker {
  0% {
    transform: scale(1);
    box-shadow: 0 0 0 currentColor;
  }
  50% {
    transform: scale(1.5);
    box-shadow: 0 0 18px currentColor;
  }
  100% {
    transform: scale(1);
    box-shadow: 0 0 0 currentColor;
  }
}
</style>
