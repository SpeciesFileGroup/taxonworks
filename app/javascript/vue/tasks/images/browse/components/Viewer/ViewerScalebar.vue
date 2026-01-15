<template>
  <g
    class="scalebar"
    :transform="`translate(${x}, ${y})`"
  >
    <rect
      class="scalebar-bar"
      :width="width"
      height="6"
    />

    <text
      class="scalebar-text"
      :x="width / 2"
      y="-6"
      text-anchor="middle"
      font-size="12"
    >
      {{ label }}
    </text>
  </g>
</template>

<script setup>
const props = defineProps({
  x: {
    type: Number,
    required: true
  },

  y: {
    type: Number,
    required: true
  },

  width: {
    type: Number,
    required: true
  },

  label: {
    type: String,
    required: true
  }
})
</script>

<style scoped>
.scalebar-bar,
.scalebar-text {
  fill: white;
  mix-blend-mode: difference;
}

.scalebar-text {
  paint-order: stroke;
  stroke: black;
  stroke-width: 1.5;
}
</style>
