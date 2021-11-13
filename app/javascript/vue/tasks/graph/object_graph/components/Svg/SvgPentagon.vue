<template>
  <polygon
    :points="points"
    :width="size"
    :height="size"
    :fill="color"
    :transform="`rotate(18, ${x - size/1.8}, ${y - size/1.8}) translate(${x - size/1.8}, ${y - size/1.8})`"
  />
</template>
<script setup>

const props = defineProps({
  size: {
    type: Number,
    required: true
  },
  color: {
    type: String,
    required: true
  },
  x: {
    type: Number,
    required: true
  },
  y: {
    type: Number,
    required: true
  }
})

const points = [...Array(6)].map((_, i) => {
  const angleDeg = 72 * i - 36
  const angleRad = Math.PI / 180 * angleDeg

  return [props.size / 1.8 + props.size * Math.cos(angleRad), props.size / 1.8 + props.size * Math.sin(angleRad)]
}).map((p) => p.join(',')).join(' ')
</script>
