<template>
  <g class="measurement">
    <line
      :x1="x1"
      :y1="y1"
      :x2="x2"
      :y2="y2"
      class="bar"
    />

    <text
      :x="midX"
      :y="midY - 6"
      text-anchor="middle"
      dominant-baseline="central"
      :transform="textTransform"
      class="label"
    >
      {{ label }}
    </text>
  </g>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  x1: Number,
  y1: Number,
  x2: Number,
  y2: Number,
  pixelsToCentimeters: Number
})

const midX = computed(() => (props.x1 + props.x2) / 2)
const midY = computed(() => (props.y1 + props.y2) / 2)

const angle = computed(() => {
  return (Math.atan2(props.y2 - props.y1, props.x2 - props.x1) * 180) / Math.PI
})

const readableAngle = computed(() => {
  return angle.value > 90 || angle.value < -90 ? angle.value + 180 : angle.value
})

const textTransform = computed(() => {
  return `rotate(${readableAngle.value}, ${midX.value}, ${midY.value})`
})

const lengthPx = computed(() =>
  Math.hypot(props.x2 - props.x1, props.y2 - props.y1)
)

const label = computed(() => {
  const cm = lengthPx.value / props.pixelsToCentimeters
  return cm >= 1 ? `${cm.toFixed(2)} cm` : `${(cm * 10).toFixed(1)} mm`
})
</script>

<style scoped>
.bar {
  stroke: white;
  stroke-width: 2;
  mix-blend-mode: difference;
}

.label {
  fill: white;
  font-size: 12px;
  mix-blend-mode: difference;
  paint-order: stroke;
  stroke: black;
  stroke-width: 1.5;
  pointer-events: none;
}
</style>
