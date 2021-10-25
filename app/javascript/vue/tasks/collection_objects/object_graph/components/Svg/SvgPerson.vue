<template>
  <path
    :width="size"
    :height="size"
    :fill="color"
    :transform="`translate(${x - size}, ${y - size})`"
    d="M20.474 19.013a8.941 8.941 0 0 0-4.115-4.89 6 6 0 1 0-8.717 0 8.941 8.941 0 0 0-4.115 4.89 11.065 11.065 0 0 0 1.63 1.59 6.965 6.965 0 0 1 4.728-5.275 1 1 0 0 0 .181-1.829 4 4 0 1 1 3.871 0 1 1 0 0 0 .181 1.829 6.965 6.965 0 0 1 4.726 5.272 11.059 11.059 0 0 0 1.63-1.587z"
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
