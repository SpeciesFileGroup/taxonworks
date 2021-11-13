<template>
  <polygon
    :points="`
      ${x},
      ${y - size}
      ${x - size},
      ${y + size}
      ${x + size},
      ${y + size}`"
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
