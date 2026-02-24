<template>
  <g
    class="scalebar"
    :transform="`translate(${x}, ${y})`"
  >
    <rect
      :width="width"
      :height="barHeight"
      class="scalebar-bar"
    />

    <text
      :x="width / 2"
      :y="-(barHeight + 2 / zoom)"
      :font-size="fontSize"
      text-anchor="middle"
      class="scalebar-text"
    >
      {{ label }}
    </text>
  </g>
</template>

<script setup>
defineProps({
  x: Number,
  y: Number,
  width: Number,
  label: String,
  fontSize: Number,
  barHeight: Number,
  zoom: Number
})
</script>

<style scoped>
.scalebar-bar,
.scalebar-text {
  fill: black;
  paint-order: stroke;
  vector-effect: non-scaling-stroke;
}

.scalebar-text {
  stroke: white;
  stroke-width: 6;
}

.scalebar-bar-white {
  fill: white;
}
</style>
