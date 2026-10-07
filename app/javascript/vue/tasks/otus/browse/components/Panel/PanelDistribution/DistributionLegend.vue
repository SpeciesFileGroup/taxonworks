<template>
  <div
    v-if="shapeTypes.length"
    class="distribution-legend"
  >
    <div
      v-for="type in shapeTypes"
      :key="type"
      class="distribution-legend__item"
    >
      <div
        :class="['distribution-legend__swatch', MAP_LEGEND[type].background]"
      />
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

<style lang="scss" scoped>
.distribution-legend {
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem 1rem;
  padding: var(--spacing-sm) var(--spacing-md);
}

.distribution-legend__item {
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.distribution-legend__swatch {
  flex-shrink: 0;
  width: 12px;
  height: 12px;
  border-radius: var(--border-radius-xsmall);
}
</style>
