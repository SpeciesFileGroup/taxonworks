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
  gap: var(--spacing-sm) var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  font-size: var(--font-size-xs);
}

.distribution-legend__item {
  display: flex;
  align-items: center;
  gap: var(--spacing-xxs);
}

.distribution-legend__swatch {
  flex-shrink: 0;
  width: 12px;
  height: 12px;
  border-radius: var(--border-radius-xsmall);
}
</style>
