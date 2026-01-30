<template>
  <svg
    ref="svgRef"
    :viewBox="`0 0 ${viewport.width} ${viewport.height}`"
    :style="{ cursor: viewerMode.cursor.value }"
    @mousedown="onMouseDown"
    @mousemove="onMouseMove"
    @mouseup="onMouseUp"
    @wheel.prevent="onWheel"
  >
    <g
      ref="contentRef"
      class="content"
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
        v-for="group in layers"
        :key="group"
        v-html="group"
      />

      <MeasurementLayer
        :measurements="measurements"
        :pixels-to-centimeters="pixelsToCentimeters"
        :font-size="12 / zoom"
        :stroke-width="2"
        :zoom="zoom"
      />

      <component
        v-if="viewerMode.overlay.value && viewerMode.overlayProps.value"
        :is="viewerMode.overlay.value"
        v-bind="viewerMode.overlayProps.value"
      />
    </g>

    <ViewerScalebarOverlay
      v-if="pixelsToCentimeters"
      :x="viewport.width / 2 - scalebarOverlay.screenWidth / 2"
      :y="viewport.height - 24"
      :width="scalebarOverlay.screenWidth"
      :label="scalebarOverlay.label"
    />
  </svg>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useEventListener } from '@/composables'

import {
  useAutoScalebar,
  useViewerModes,
  useMeasureMode,
  usePanMode,
  useViewerTransform,
  useZoom,
  useEraseMode,
  useViewportFit,
  usePanGesture,
  useZoomGesture,
  useViewerGestures
} from '../../composables'

import MeasurementLayer from './Measurement/MeasurementLayer.vue'
import ViewerScalebarOverlay from './ViewerScalebarOverlay.vue'

const props = defineProps({
  imageUrl: { type: String, required: true },
  imageWidth: { type: Number, required: true },
  imageHeight: { type: Number, required: true },
  pixelsToCentimeters: { type: Number, required: true },
  layers: {
    type: Array,
    default: () => []
  }
})

const measurements = defineModel('measurements', {
  type: Array,
  default: () => []
})

const mode = defineModel('mode', {
  type: String,
  default: 'pan'
})

const svgRef = ref()
const contentRef = ref()

const pan = ref({ x: 0, y: 0 })
const baseZoom = ref(1)
const userZoom = ref(1)
const viewport = ref({
  width: props.imageWidth,
  height: props.imageHeight
})

const zoom = computed(() => baseZoom.value * userZoom.value)

const transform = useViewerTransform({
  svgRef,
  pan,
  zoom
})

const autoScale = useAutoScalebar({
  pixelsToCentimeters: computed(() => props.pixelsToCentimeters),
  zoom,
  targetPx: 120
})

const contentTransform = computed(
  () => `
  translate(${pan.value.x}, ${pan.value.y})
  scale(${zoom.value})
`
)

const scalebarOverlay = computed(() => {
  const cm = autoScale.value.cm

  return {
    label: cm < 1 ? `${cm * 10} mm` : `${cm} cm`,
    screenWidth: autoScale.value.px
  }
})

const ctx = {
  svgRef,
  pan,
  zoom,
  contentRef,
  measurements,
  transform,
  baseZoom,
  userZoom,
  viewport,
  pixelsToCentimeters: computed(() => props.pixelsToCentimeters),
  imageWidth: computed(() => props.imageWidth),
  imageHeight: computed(() => props.imageHeight)
}

const { fit } = useViewportFit(ctx)

const modes = {
  pan: usePanMode(ctx),
  measure: useMeasureMode(ctx),
  erase: useEraseMode(ctx),
  zoom: useZoom(ctx)
}

const viewerMode = useViewerModes({
  mode,
  modes
})

const viewerGestures = useViewerGestures({
  pan: usePanGesture(ctx),
  zoom: useZoomGesture(ctx)
})

function onKeyDown(e) {
  viewerMode.onKeyDown(e)
}

function onKeyUp(e) {
  viewerMode.onKeyUp(e)
}

function onMouseDown(e) {
  viewerGestures.onMouseDown(e)
  viewerMode.onMouseDown(e)
}

function onMouseMove(e) {
  viewerGestures.onMouseMove(e)
  viewerMode.onMouseMove(e)
}

function onMouseUp(e) {
  viewerGestures.onMouseUp(e)
  viewerMode.onMouseUp(e)
}

function onWheel(e) {
  viewerGestures.onWheel(e)
}

useEventListener(window, 'keyup', onKeyUp)
useEventListener(window, 'keydown', onKeyDown)
</script>

<style scoped>
svg {
  user-select: none;
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
</style>
