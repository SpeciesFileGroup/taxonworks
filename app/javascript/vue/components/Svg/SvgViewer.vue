<template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="1.1"
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
        v-for="group in shapes"
        :key="group"
        v-html="group"
      ></g>
    </g>
  </svg>
</template>

<script setup>
import { useOnResize } from '@/compositions'
import { ref, onMounted, computed, watch } from 'vue'

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
const size = useOnResize(svgElement)

const shapes = computed(() => {
  return props.groups
    .map(({ g, attributes = {} }) => {
      const el = createGroupElement(g)
      const shapes = [...el.children].map((child) => {
        const shape = child.firstChild

        Object.entries(attributes).forEach(([attribute, value]) => {
          shape.setAttribute(attribute, value)
        })

        return child.innerHTML
      })

      return shapes
    })
    .flat()
})

function createGroupElement(text) {
  const el = document.createElementNS('http://www.w3.org/2000/svg', 'g')
  el.innerHTML = text

  return el.firstChild
}

function updateScale() {
  const size = svgElement.value.getBoundingClientRect()
  const cWidth = parseInt(size.width)
  const cHeight = parseInt(size.height)

  const cAR = cWidth / cHeight
  const iAR = props.image.width / props.image.height

  if (
    (((cAR >= 1 && iAR >= 1) || (cAR <= 1 && iAR <= 1)) && iAR <= cAR) ||
    (iAR <= 1 && cAR >= 1)
  ) {
    scale.value = size.height / props.image.height
  } else {
    scale.value = size.width / props.image.width
  }
}

watch(size, () => {
  updateScale()
})

onMounted(() => {
  updateScale()
})
</script>
