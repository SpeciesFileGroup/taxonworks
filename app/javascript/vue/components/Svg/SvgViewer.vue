<template>
  <svg
    id="svgLayer"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.1"
    style="position: inherit"
    width="546"
    height="457"
  >
    <g transform="translate(0, 0) scale(1)">
      <image
        x="0"
        y="0"
        :width="image.width"
        :height="image.height"
        preserveAspectRatio="none"
        :xlink:href="image.url"
      ></image>
      <g
        v-for="group in groups"
        :key="group"
        v-html="group"
      ></g>
    </g>
  </svg>
</template>

<script setup>
defineProps({
  image: {
    type: String,
    required: true
  },
  groups: {
    type: Array,
    default: () => []
  }
})
</script>
