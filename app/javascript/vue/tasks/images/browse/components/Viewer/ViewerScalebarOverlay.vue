<template>
  <g
    class="scalebar-overlay"
    :transform="`translate(${x}, ${y})`"
  >
    <rect
      :width="width"
      :height="barHeight"
      class="scalebar-bar-white"
    />

    <rect
      :y="blackY"
      :width="width"
      :height="blackHeight"
      class="scalebar-bar"
    />

    <text
      :x="width / 2"
      :y="-(barHeight + textOffset)"
      :font-size="fontSize"
      text-anchor="middle"
      class="scalebar-text"
    >
      {{ label }}
    </text>
  </g>
</template>

<script setup>
import { computed } from 'vue'
const props = defineProps({
  x: Number,
  y: Number,
  width: Number,
  label: String,
  fontSize: {
    type: Number,
    default: 12
  },
  barHeight: {
    type: Number,
    default: 4
  }
})

const blackHeight = computed(() => props.barHeight / 3)
const blackY = computed(() => (props.barHeight - blackHeight.value) / 2)
const textOffset = computed(() => props.fontSize * 0.1)
</script>

<style scoped>
.scalebar-bar {
  fill: black;
  vector-effect: non-scaling-stroke;
}

.scalebar-bar-white {
  fill: white;
  vector-effect: non-scaling-stroke;
}

.scalebar-text {
  fill: black;
  paint-order: stroke;
  stroke: white;
  stroke-width: 6;
  vector-effect: non-scaling-stroke;
}
</style>
