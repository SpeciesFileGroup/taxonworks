<template>
  <svg
    ref="root"
    xmlns="http://www.w3.org/2000/svg"
    :style="{
      width: width || elementSize,
      height: height || elementSize
    }"
    :viewBox="viewbox"
    :aria-labelledby="name"
    role="presentation"
  >
    <title
      :id="name"
      lang="en"
    >
      {{ title }}
    </title>
    <g
      ref="svggroup"
      stroke-width="2"
      :fill="selectedColor"
    >
      <path
        v-for="(path, index) in iconPaths"
        :key="index"
        v-bind="path"
      />
    </g>
  </svg>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { onVisible } from '@/helpers/observable.js'
import { useSizes, useColors, sizeProps, colorProps } from '@/composables'
import * as Icons from './icons.js'

defineOptions({ name: 'VIcon' })

const props = defineProps({
  ...sizeProps,
  ...colorProps,

  disabled: {
    type: Boolean,
    default: false
  },

  name: {
    type: String,
    required: true
  },

  title: {
    type: String,
    default: undefined
  },

  width: {
    type: String,
    default: undefined
  },

  height: {
    type: String,
    default: undefined
  }
})

const { elementSize } = useSizes(props)
const { selectedColor } = useColors(props)

const viewbox = ref('0 0 12 12')
const root = ref(null)
const svggroup = ref(null)

let observer

const iconPaths = computed(() => Icons[props.name]?.paths || [])

function getViewboxSize() {
  const refGroup = svggroup.value

  if (refGroup) {
    const groupSize = refGroup.getBBox()
    const strokePaths = iconPaths.value
      .map((path) => path['stroke-width'])
      .filter((stroke) => stroke)
    const strokeWidth = strokePaths.length ? Math.max(...strokePaths) : 0

    return [
      groupSize.x - strokeWidth / 2,
      groupSize.y - strokeWidth / 2,
      groupSize.width + strokeWidth,
      groupSize.height + strokeWidth
    ].join(' ')
  } else {
    return '0 0 12 12'
  }
}

watch(
  () => props.name,
  () => {
    nextTick(() => {
      viewbox.value = getViewboxSize()
    })
  }
)

onMounted(() => {
  nextTick(() => {
    viewbox.value = getViewboxSize()
  })

  const { observer: visibilityObserver } = onVisible(root.value, (visible) => {
    if (visible) {
      nextTick(() => {
        viewbox.value = getViewboxSize()
      })
    }
  })

  observer = visibilityObserver
})

onUnmounted(() => {
  observer?.disconnect()
})
</script>
