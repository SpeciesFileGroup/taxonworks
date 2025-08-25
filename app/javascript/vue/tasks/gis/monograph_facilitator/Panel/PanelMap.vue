<template>
  <VMap
    height="100%"
    width="100%"
    fit-bounds
    resize
    selection
    tooltips
    :geojson="store.shapes"
    @layer:click="handleClick"
    @layer:mouseover="handleMouseOver"
    @layer:mouseout="handleMouseOut"
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
  const geoIds = features.map((f) => f.properties.georeference.id)
  const objects = geoIds.map((id) => store.getObjectByGeoreferenceId(id)).flat()

  let newIds = objects.map((o) => o.id)

  if (isKeyPressed('Shift')) {
    if (isKeyPressed('Control')) {
      const added = newIds.filter((id) => !store.selectedIds.includes(id))
      const remaining = store.selectedIds.filter((id) => !newIds.includes(id))

      newIds = [...remaining, ...added]
    } else {
      newIds = [...store.selectedIds, ...newIds]
    }
  }

  store.selectedIds = [...new Set(newIds)]
}

function handleMouseOut() {
  store.hoverIds = []
}

function handleMouseOver({ feature }) {
  store.hoverIds = feature.properties.objectIds
}

function handleClick({ feature }) {
  store.clickedLayer = feature
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
