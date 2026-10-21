<template>
  <div
    ref="rootEl"
    class="lt-canvas"
    :class="{ 'lt-canvas--pan': panMode }"
    @pointerdown="onBgPointerDown"
    @dragover="onDragOver"
    @drop="onDrop"
  >
    <div
      ref="surfaceEl"
      class="lt-canvas__surface"
      :style="surfaceStyle"
    >
      <LightTableRegion
        v-for="region in lightTable.regions"
        :key="region.id"
        :region="region"
        :readonly="readonly"
      />
      <LightTableItem
        v-for="item in lightTable.items"
        :key="item.id"
        :item="item"
        :selected="lightTable.selection.has(item.id)"
        :readonly="readonly"
      >
        <template #overlay="slotProps">
          <slot
            name="item-overlay"
            v-bind="slotProps"
          />
        </template>
      </LightTableItem>
      <div
        v-if="marquee.state.active"
        class="lt-canvas__marquee"
        :style="marqueeStyle"
      />
    </div>
  </div>
</template>

<script setup>
import { inject, provide, ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { usePointerDrag } from '../composables/usePointerDrag.js'
import { useMarquee } from '../composables/useMarquee.js'
import LightTableItem from './LightTableItem.vue'
import LightTableRegion from './LightTableRegion.vue'

const props = defineProps({
  readonly: {
    type: Boolean,
    default: false
  },

  dropTypes: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['drop-external'])

const lightTable = inject('lightTable')
const panMode = inject('panMode')

const rootEl = ref(null)
const surfaceEl = ref(null)
const marquee = useMarquee()

provide('getCanvasRect', () => rootEl.value.getBoundingClientRect())

const surfaceStyle = computed(() => {
  const vp = lightTable.viewport.state

  return {
    transform: `translate(${vp.panX}px, ${vp.panY}px) scale(${vp.zoom})`,
    transformOrigin: '0 0'
  }
})

const marqueeStyle = computed(() => {
  const r = marquee.rect.value

  return {
    left: `${r.x}px`,
    top: `${r.y}px`,
    width: `${r.w}px`,
    height: `${r.h}px`
  }
})

let dragMode = null
let panStart = null
let shiftAtStart = false

function canvasPoint(event) {
  const rect = rootEl.value.getBoundingClientRect()

  return lightTable.viewport.screenToCanvas(event.clientX, event.clientY, rect)
}

const startBg = usePointerDrag({
  onStart({ event, button }) {
    shiftAtStart = event.shiftKey
    if (button === 1 || panMode.value) {
      dragMode = 'pan'
      panStart = {
        panX: lightTable.viewport.state.panX,
        panY: lightTable.viewport.state.panY
      }
    } else {
      dragMode = 'marquee'
      const p = canvasPoint(event)
      marquee.begin(p.x, p.y)
    }
  },
  onMove({ event, total }) {
    if (dragMode === 'pan') {
      lightTable.viewport.state.panX = panStart.panX + total.x
      lightTable.viewport.state.panY = panStart.panY + total.y
    } else if (dragMode === 'marquee') {
      const p = canvasPoint(event)
      marquee.move(p.x, p.y)
    }
  },
  onEnd() {
    if (dragMode === 'marquee') {
      const rect = marquee.finish()
      if (rect && rect.w > 2 && rect.h > 2) {
        const hits = lightTable.itemsIntersecting(rect).map((it) => it.id)
        if (shiftAtStart) lightTable.addToSelection(hits)
        else lightTable.selectOnly(hits)
      } else if (!shiftAtStart) {
        lightTable.clearSelection()
      }
    }
    dragMode = null
    panStart = null
  }
})

function onBgPointerDown(event) {
  if (event.target !== rootEl.value && event.target !== surfaceEl.value) return
  startBg(event)
}

function onWheel(event) {
  event.preventDefault()
  const rect = rootEl.value.getBoundingClientRect()
  const factor = event.deltaY < 0 ? 1.1 : 1 / 1.1
  lightTable.viewport.zoomAt(event.clientX, event.clientY, factor, rect)
}

function isAcceptedDrop(event) {
  const types = event.dataTransfer?.types || []

  return !props.readonly && props.dropTypes.some((t) => types.includes(t))
}

function onDragOver(event) {
  if (!isAcceptedDrop(event)) return
  event.preventDefault()
  event.dataTransfer.dropEffect = 'copy'
}

function onDrop(event) {
  if (!isAcceptedDrop(event)) return
  event.preventDefault()
  emit('drop-external', {
    point: canvasPoint(event),
    dataTransfer: event.dataTransfer
  })
}

onMounted(() => {
  rootEl.value.addEventListener('wheel', onWheel, { passive: false })
})

onBeforeUnmount(() => {
  rootEl.value?.removeEventListener('wheel', onWheel)
})

defineExpose({
  getCanvasRect: () => rootEl.value?.getBoundingClientRect() ?? null
})
</script>

<style scoped>
.lt-canvas {
  position: relative;
  overflow: hidden;
  width: 100%;
  height: 100%;
  background-color: var(--bg-muted);
  background-image:
    linear-gradient(
      color-mix(in srgb, var(--border-color) 45%, transparent) 1px,
      transparent 1px
    ),
    linear-gradient(
      90deg,
      color-mix(in srgb, var(--border-color) 45%, transparent) 1px,
      transparent 1px
    );
  background-size: 40px 40px;
  cursor: default;
  touch-action: none;
}

.lt-canvas--pan {
  cursor: grab;
}

.lt-canvas--pan:active {
  cursor: grabbing;
}

.lt-canvas__surface {
  position: absolute;
  left: 0;
  top: 0;
  width: 0;
  height: 0;
  will-change: transform;
}

.lt-canvas__marquee {
  position: absolute;
  border: 1px dashed var(--color-primary);
  background: color-mix(in srgb, var(--color-primary) 10%, transparent);
  pointer-events: none;
}
</style>
