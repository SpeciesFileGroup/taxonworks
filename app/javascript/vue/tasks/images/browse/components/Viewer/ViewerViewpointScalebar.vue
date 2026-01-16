<template>
  <g :transform="`translate(${x}, ${y})`">
    <rect
      :width="screenWidth"
      height="6"
      fill="black"
    />

    <text
      :x="screenWidth / 2"
      :y="-(fontSize + 4)"
      text-anchor="middle"
      dominant-baseline="alphabetic"
      :font-size="fontSize"
      fill="black"
    >
      {{ label }}
    </text>
  </g>
</template>

<script setup>
import { computed } from 'vue'

const BASE_FONT = 36
const MIN_FONT = 32
const MAX_FONT = 64

const props = defineProps({
  zoom: Number,
  pixelsToCentimeters: Number,
  viewerWidth: Number,
  viewerHeight: Number
})

const TARGET_SCREEN_PX = 120

const realPx = computed(() => TARGET_SCREEN_PX / props.zoom)

const cm = computed(() => realPx.value / props.pixelsToCentimeters)

const fontSize = computed(() => {
  return Math.min(
    MAX_FONT,
    Math.max(MIN_FONT, BASE_FONT * Math.sqrt(props.zoom))
  )
})

function nice(v) {
  const steps = [0.1, 0.2, 0.5, 1, 2, 5, 10]
  return steps.find((s) => s >= v) || steps.at(-1)
}

const niceCm = computed(() => nice(cm.value))

const screenWidth = computed(
  () => niceCm.value * props.pixelsToCentimeters * props.zoom
)

const label = computed(() =>
  niceCm.value >= 1 ? `${niceCm.value} cm` : `${niceCm.value * 10} mm`
)

const x = 20
const y = props.viewerHeight - 20
</script>
