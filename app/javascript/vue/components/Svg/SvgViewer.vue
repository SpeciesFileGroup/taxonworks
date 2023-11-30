<template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.1"
    style="position: inherit"
    width="546"
    height="457"
    ref="svgElement"
  >
    <g :transform="`translate(0, 0) scale(${parseFloat(scale)})`">
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
import { ref, onMounted } from 'vue'

const props = defineProps({
  image: {
    type: Object,
    required: true
  },
  groups: {
    type: Array,
    default: () => []
  }
})

const svgElement = ref()
const scale = ref(1)

function updateScale() {
  const size = svgElement.value.getBoundingClientRect()
  const cWidth = parseInt(size.width)
  const cHeight = parseInt(size.height)

  const cAR = cWidth / cHeight
  const iAR = props.image.width / props.image.height

  // scale to height if (similar aspect ratios AND image aspect ratio less than container's)
  // OR the image is tall and the container is wide)
  if (
    (((cAR >= 1 && iAR >= 1) || (cAR <= 1 && iAR <= 1)) && iAR <= cAR) ||
    (iAR <= 1 && cAR >= 1)
  ) {
    scale.value = size.height / props.image.height
  } else {
    scale.value = size.width / props.image.width
  }
}

onMounted(() => {
  updateScale()
})
</script>
