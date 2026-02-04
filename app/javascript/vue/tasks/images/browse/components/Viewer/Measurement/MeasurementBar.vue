<template>
  <g class="measurement">
    <line
      :x1="x1"
      :y1="y1"
      :x2="x2"
      :y2="y2"
      :stroke-width="strokeWidth * 2"
      class="bar-halo"
    />

    <!-- línea principal -->
    <line
      :x1="x1"
      :y1="y1"
      :x2="x2"
      :y2="y2"
      :stroke-width="strokeWidth"
      class="bar"
    />

    <text
      :x="midX"
      :y="midY - textOffset"
      text-anchor="middle"
      dominant-baseline="central"
      :transform="textTransform"
      class="label"
      :font-size="fontSize"
    >
      {{ label }}
    </text>
  </g>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  x1: { type: Number, required: true },

  y1: { type: Number, required: true },

  x2: { type: Number, required: true },

  y2: { type: Number, required: true },

  pixelsToCentimeters: { type: Number, required: true },

  fontSize: {
    type: Number,
    default: 12
  },
  strokeWidth: {
    type: Number,
    default: 2
  }
})

const midX = computed(() => (props.x1 + props.x2) / 2)
const midY = computed(() => (props.y1 + props.y2) / 2)

const angle = computed(
  () => (Math.atan2(props.y2 - props.y1, props.x2 - props.x1) * 180) / Math.PI
)

const readableAngle = computed(() =>
  angle.value > 90 || angle.value < -90 ? angle.value + 180 : angle.value
)

const textTransform = computed(
  () => `rotate(${readableAngle.value}, ${midX.value}, ${midY.value})`
)

const lengthPx = computed(() =>
  Math.hypot(props.x2 - props.x1, props.y2 - props.y1)
)

const label = computed(() => {
  const cm = lengthPx.value / props.pixelsToCentimeters
  return cm >= 1 ? `${cm.toFixed(2)} cm` : `${(cm * 10).toFixed(1)} mm`
})

const textOffset = computed(() => props.fontSize * 0.6)
</script>
<style scoped>
.bar-halo {
  stroke: white;
  vector-effect: non-scaling-stroke;
}

.bar {
  stroke: black;
  vector-effect: non-scaling-stroke;
}

.label {
  fill: black;
  paint-order: stroke;
  stroke: white;
  stroke-width: 6;
  stroke-linejoin: round;
  vector-effect: non-scaling-stroke;
}
</style>
