<template>
  <g class="measurement-layer">
    <MeasurementBar
      v-for="(m, i) in measurements"
      :key="i"
      v-bind="m"
      :pixels-to-centimeters="pixelsToCentimeters"
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
  }
})
</script>
