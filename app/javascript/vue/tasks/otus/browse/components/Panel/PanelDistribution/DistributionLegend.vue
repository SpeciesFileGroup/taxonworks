<template>
  <div
    class="flex flex-row gap-small middle margin-medium-top"
    v-if="shapeTypes.length"
  >
    <div
      v-for="type in shapeTypes"
      :key="type"
      class="flex flex-row middle gap-xsmall"
    >
      <div :class="['legend-square', MAP_LEGEND[type].background]" />
      <span>{{ MAP_LEGEND[type].label }}</span>
    </div>
  </div>
</template>

<script setup>
import { MAP_LEGEND } from './constants/mapLegend.js'

defineProps({
  shapeTypes: {
    type: Array,
    default: () => []
  }
})
</script>

<style scoped>
.legend-square {
  border-radius: 0.125rem;
  width: 12px;
  height: 12px;
}
</style>
