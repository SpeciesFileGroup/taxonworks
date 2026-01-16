<template>
  <svg
    ref="svgRef"
    :viewBox="`0 0 ${viewport.width} ${viewport.height}`"
    @mousedown="onMouseDown"
    @mousemove="onMouseMove"
    @mouseup="onMouseUp"
    @dblclick="resetView"
    @wheel.prevent="onWheel"
  >
    <g
      class="content"
      ref="contentRef"
      :transform="contentTransform"
    >
      <image
        :href="imageUrl"
        x="0"
        y="0"
        :width="imageWidth"
        :height="imageHeight"
      />

      <g
        v-for="group in shapes"
        :key="group"
        v-html="group"
      />

      <MeasurementLayer
        :measurements="measurements"
        :pixels-to-centimeters="pixelsToCentimeters"
      />

      <MeasurementBar
        v-if="drawing"
        :x1="startPoint.x"
        :y1="startPoint.y"
        :x2="currentPoint.x"
        :y2="currentPoint.y"
        :pixels-to-centimeters="pixelsToCentimeters"
        preview
      />

      <ViewerScalebar
        :x="imageWidth / 2"
        :y="imageHeight - 20"
        :width="scalebarWidth"
        :label="scalebarLabel"
      />
    </g>

    <ViewerScalebar
      v-if="false"
      :x="scalebarX"
      :y="scalebarY"
      :width="scalebarWidth"
      :label="scalebarLabel"
    />
  </svg>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useMeasurements } from '../../composables/useMeasurements'
import ViewerScalebar from './ViewerScalebar.vue'
import MeasurementLayer from './Measurement/MeasurementLayer.vue'
import MeasurementBar from './Measurement/MeasurementBar.vue'

const props = defineProps({
  imageUrl: { type: String, required: true },
  imageWidth: { type: Number, required: true },
  imageHeight: { type: Number, required: true },
  pixelsToCentimeters: { type: Number, required: true },
  shapes: {
    type: Array,
    default: () => []
  }
})

const viewport = ref({
  width: props.imageWidth,
  height: props.imageHeight
})

const pan = ref({ x: 0, y: 0 })
const zoom = ref(1)

const contentRef = ref()

const contentTransform = computed(() => {
  return `
    translate(${pan.value.x}, ${pan.value.y})
    scale(${zoom.value})
  `
})

const SCALEBAR_CM = 1

const scalebarWidth = computed(() => {
  return props.pixelsToCentimeters * SCALEBAR_CM
})

const scalebarLabel = `${SCALEBAR_CM} cm`

const scalebarX = computed(() => {
  return (viewport.value.width - scalebarWidth.value) / 2
})

const scalebarY = computed(() => {
  return viewport.value.height - 20
})

const svgRef = ref(null)

const {
  measurements,
  drawing,
  startPoint,
  currentPoint,
  startMeasurement,
  moveMeasurement,
  endMeasurement
} = useMeasurements(svgRef, contentRef)

function svgPoint(evt, svg) {
  const pt = svg.createSVGPoint()
  pt.x = evt.clientX
  pt.y = evt.clientY
  return pt.matrixTransform(svg.getScreenCTM().inverse())
}

function onWheel(e) {
  const zoomFactor = e.deltaY < 0 ? 1.1 : 0.9
  const pt = svgPoint(e, svgRef.value)

  pan.value.x = pt.x - (pt.x - pan.value.x) * zoomFactor
  pan.value.y = pt.y - (pt.y - pan.value.y) * zoomFactor

  zoom.value *= zoomFactor
}

const panning = ref(false)
const panStartMouse = ref(null)
const panStartPan = ref(null)

function startPan(e) {
  panning.value = true
  panStartMouse.value = { x: e.clientX, y: e.clientY }
  panStartPan.value = { ...pan.value }
}

function movePan(e) {
  if (!panning.value) return

  const dx = e.clientX - panStartMouse.value.x
  const dy = e.clientY - panStartMouse.value.y

  pan.value.x = panStartPan.value.x + dx
  pan.value.y = panStartPan.value.y + dy
}

function endPan() {
  panning.value = false
}

function onMouseDown(e) {
  if (e.shiftKey) {
    startMeasurement(e)
  } else {
    startPan(e)
  }
}

function onMouseMove(e) {
  moveMeasurement(e)
  movePan(e)
}

function onMouseUp() {
  endMeasurement()
  endPan()
}

function fitImageToViewer() {
  const vw = svgRef.value.clientWidth
  const vh = svgRef.value.clientHeight

  viewport.value = { width: vw, height: vh }

  const scale = Math.min(1, vw / props.imageWidth, vh / props.imageHeight)

  zoom.value = scale

  pan.value = {
    x: (vw - props.imageWidth * scale) / 2,
    y: (vh - props.imageHeight * scale) / 2
  }
}

function resetView() {
  fitImageToViewer()
}

let resizeObserver

watch(() => [props.imageWidth, props.imageHeight], fitImageToViewer)

onMounted(() => {
  fitImageToViewer()

  resizeObserver = new ResizeObserver(() => {
    fitImageToViewer()
  })

  resizeObserver.observe(svgRef.value)
})

onBeforeUnmount(() => {
  resizeObserver?.disconnect()
})
</script>

<style scoped>
.viewer {
  user-select: none;
  cursor: crosshair;
}

svg * {
  user-select: none;
}

.content,
.content * {
  pointer-events: none;
}

svg {
  pointer-events: all;
}

.overlay,
.overlay * {
  pointer-events: none;
}
</style>
