<template>
  <svg
    ref="svgRef"
    :viewBox="`${viewBox.x} ${viewBox.y} ${viewBox.width} ${viewBox.height}`"
    :width="width"
    :height="height"
    @mousedown="onMouseDown"
    @mousemove="onMouseMove"
    @mouseup="onMouseUp"
    @dblclick="resetView"
    @wheel="onWheel"
  >
    <!-- Imagen -->
    <image
      :href="imageUrl"
      x="0"
      y="0"
      :width="width"
      :height="height"
      preserveAspectRatio="xMidYMid meet"
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
      :x="scalebarX"
      :y="scalebarY"
      :width="scalebarWidth"
      :label="scalebarLabel"
    />
  </svg>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useMeasurements } from '../../composables/useMeasurements'
import ViewerScalebar from './ViewerScalebar.vue'
import MeasurementLayer from './Measurement/MeasurementLayer.vue'
import MeasurementBar from './Measurement/MeasurementBar.vue'

const props = defineProps({
  imageUrl: String,
  width: { type: Number, default: 800 },
  height: { type: Number, default: 600 },
  pixelsToCentimeters: { type: Number, required: true }
})

const viewBox = ref({
  x: 0,
  y: 0,
  width: props.width,
  height: props.height
})

const SCALEBAR_CM = 1

const scalebarWidth = computed(() => {
  return props.pixelsToCentimeters * SCALEBAR_CM
})

const scalebarLabel = `${SCALEBAR_CM} cm`

const scalebarX = computed(() => {
  return (props.width - scalebarWidth.value) / 2
})

const scalebarY = props.height - 20

const svgRef = ref(null)

const {
  measurements,
  drawing,
  startPoint,
  currentPoint,
  startMeasurement,
  moveMeasurement,
  endMeasurement
} = useMeasurements(svgRef, props.pixelsToCentimeters)

function svgPoint(evt, svg) {
  const pt = svg.createSVGPoint()
  pt.x = evt.clientX
  pt.y = evt.clientY
  return pt.matrixTransform(svg.getScreenCTM().inverse())
}

function onWheel(e) {
  e.preventDefault()

  const zoomFactor = e.deltaY < 0 ? 0.9 : 1.1

  const pt = svgPoint(e, svgRef.value)

  const newWidth = viewBox.value.width * zoomFactor
  const newHeight = viewBox.value.height * zoomFactor

  viewBox.value.x = pt.x - (pt.x - viewBox.value.x) * zoomFactor
  viewBox.value.y = pt.y - (pt.y - viewBox.value.y) * zoomFactor
  viewBox.value.width = newWidth
  viewBox.value.height = newHeight
}

const panning = ref(false)
const panStartMouse = ref(null)
const panStartViewBox = ref(null)

function startPan(e) {
  panning.value = true

  panStartMouse.value = {
    x: e.clientX,
    y: e.clientY
  }

  panStartViewBox.value = { ...viewBox.value }
}

function movePan(e) {
  if (!panning.value) return

  const dx = e.clientX - panStartMouse.value.x
  const dy = e.clientY - panStartMouse.value.y

  const scaleX = viewBox.value.width / svgRef.value.clientWidth
  const scaleY = viewBox.value.height / svgRef.value.clientHeight

  viewBox.value.x = panStartViewBox.value.x - dx * scaleX
  viewBox.value.y = panStartViewBox.value.y - dy * scaleY
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

function resetView() {
  viewBox.value = {
    x: 0,
    y: 0,
    width: props.width,
    height: props.height
  }
}
</script>
