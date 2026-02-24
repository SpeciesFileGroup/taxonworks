<template>
  <g class="measurement-layer">
    <MeasurementBar
      v-for="(m, i) in measurements"
      :key="i"
      v-bind="m"
      :pixels-to-centimeters="pixelsToCentimeters"
      :font-size="fontSize"
      :stroke-width="strokeWidth"
    />
  </g>
</template>

<script setup>
import MeasurementBar from './MeasurementBar.vue'

defineProps({
  measurements: {
    type: Array,
    required: true
  },
  pixelsToCentimeters: {
    type: Number,
    required: true
  },
  fontSize: {
    type: Number,
    default: 12
  },
  strokeWidth: {
    type: Number,
    default: 2
  },
  zoom: {
    type: Number,
    required: true
  }
})
</script>
