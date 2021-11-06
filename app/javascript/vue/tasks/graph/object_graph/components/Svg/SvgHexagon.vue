<template>
  <polygon
    :points="points"
    :width="size"
    :height="size"
    :fill="color"
    :transform="`translate(${x - size/2}, ${y - size/2})`"
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

const points = [...Array(7)].map((_, i) => {
  const angleDeg = 60 * i - 30
  const angleRad = Math.PI / 180 * angleDeg

  return [props.size / 2 + props.size * Math.cos(angleRad), props.size / 2 + props.size * Math.sin(angleRad)]
}).map((p) => p.join(',')).join(' ')

</script>
