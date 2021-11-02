<template>
  <rect
    :width="size * 2"
    :height="size * 2"
    :x="x - size"
    :y="y - size"
    :fill="color"
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
</script>
