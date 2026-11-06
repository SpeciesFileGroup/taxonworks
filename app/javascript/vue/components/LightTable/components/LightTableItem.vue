<template>
  <div
    class="lt-item"
    :class="{ 'lt-item--selected': selected }"
    :data-lt-item-id="item.id"
    :style="style"
    @pointerdown="onBodyPointerDown"
  >
    <svg
      v-if="hasMediaSize"
      class="lt-item__media"
      :viewBox="viewBox"
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs v-if="clipShapes">
        <clipPath
          :id="clipId"
          v-html="clipShapes"
        />
      </defs>
      <image
        :href="item.src"
        x="0"
        y="0"
        :width="item.mediaWidth"
        :height="item.mediaHeight"
        :clip-path="clipShapes ? `url(#${clipId})` : undefined"
      />
    </svg>
    <img
      v-else
      class="lt-item__media"
      :src="item.src"
      :alt="item.alt"
      draggable="false"
      @load="onImgLoad"
    />
    <slot
      name="overlay"
      :item="item"
      :selected="selected"
    />
    <div
      v-if="item.label || (selected && !readonly)"
      class="lt-item__label"
      :class="{ 'lt-item__label--empty': !item.label }"
      @pointerdown.stop
      @click.stop
    >
      <input
        v-if="editingLabel"
        ref="labelInputEl"
        v-model="labelDraft"
        class="lt-item__label-input"
        type="text"
        @blur="commitLabel"
        @keydown.enter.prevent="commitLabel"
        @keydown.escape.prevent="cancelLabel"
      />
      <span
        v-else
        class="lt-item__label-text"
        @dblclick="startLabelEdit"
      >{{
        item.label || 'Double-click to add label'
      }}</span>
    </div>
    <template v-if="selected && !readonly">
      <div
        class="lt-handle lt-handle--rotate"
        title="Rotate"
        @pointerdown="onRotatePointerDown"
      />
      <div
        v-for="corner in CORNERS"
        :key="corner"
        class="lt-handle lt-handle--scale"
        :class="`lt-handle--${corner}`"
        title="Scale"
        @pointerdown="onScalePointerDown"
      />
    </template>
  </div>
</template>

<script setup>
import { inject, computed, ref, nextTick, watch } from 'vue'
import { usePointerDrag } from '../composables/usePointerDrag.js'
import { MAX_ITEM_WIDTH } from '../composables/useLightTable.js'
import { clipPathShapes } from '../utils/svg.js'
import { fitSize } from '../utils/geometry.js'

const CORNERS = ['tl', 'tr', 'bl', 'br']

const props = defineProps({
  item: {
    type: Object,
    required: true
  },

  selected: {
    type: Boolean,
    default: false
  },

  readonly: {
    type: Boolean,
    default: false
  }
})

const lightTable = inject('lightTable')
const getCanvasRect = inject('getCanvasRect')
const regionRing = inject('regionRing', { value: false })

const regionColor = computed(() => lightTable.regionColorFor(props.item))

const hasMediaSize = computed(
  () => !!(props.item.mediaWidth && props.item.mediaHeight)
)

const viewBox = computed(
  () =>
    props.item.viewBox ||
    `0 0 ${props.item.mediaWidth} ${props.item.mediaHeight}`
)

const clipId = computed(() => `lt-clip-${props.item.id}`)
const clipShapes = computed(() => clipPathShapes(props.item.clipPath))

const style = computed(() => {
  const { w, h, scale, x, y, rotation, opacity, z } = props.item
  const out = {
    width: `${w * scale}px`,
    height: `${h * scale}px`,
    transform: `translate(-50%, -50%) translate(${x}px, ${y}px) rotate(${rotation}deg)`,
    opacity,
    zIndex: z
  }

  if (regionColor.value) {
    out['--lt-selection'] = regionColor.value
    if (regionRing.value) {
      out.boxShadow = `inset 0 0 0 4px ${regionColor.value}, var(--panel-shadow)`
    }
  }

  return out
})

function itemCenterClient() {
  const rect = getCanvasRect()
  const vp = lightTable.viewport.state

  return {
    x: rect.left + vp.panX + props.item.x * vp.zoom,
    y: rect.top + vp.panY + props.item.y * vp.zoom
  }
}

const startBody = usePointerDrag({
  onStart({ event }) {
    if (event.shiftKey || event.metaKey || event.ctrlKey) {
      lightTable.toggleSelect(props.item.id)
    } else if (!props.selected) {
      lightTable.selectOnly([props.item.id])
    }
  },
  onMove({ delta }) {
    if (props.readonly) return
    const zoom = lightTable.viewport.state.zoom
    const dx = delta.x / zoom
    const dy = delta.y / zoom

    if (lightTable.selection.has(props.item.id)) {
      lightTable.nudgeSelected(dx, dy)
    } else {
      lightTable.transformItem(props.item.id, {
        x: props.item.x + dx,
        y: props.item.y + dy
      })
    }
  }
})

function onBodyPointerDown(event) {
  startBody(event)
}

let rotateStart = null
const startRotate = usePointerDrag({
  onStart({ event }) {
    const c = itemCenterClient()
    rotateStart = {
      angle: Math.atan2(event.clientY - c.y, event.clientX - c.x),
      rotation: props.item.rotation
    }
  },
  onMove({ event }) {
    if (!rotateStart) return
    const c = itemCenterClient()
    const current = Math.atan2(event.clientY - c.y, event.clientX - c.x)
    const deltaDeg = ((current - rotateStart.angle) * 180) / Math.PI

    lightTable.transformItem(props.item.id, {
      rotation: rotateStart.rotation + deltaDeg
    })
  },
  onEnd() {
    rotateStart = null
  }
})

function onRotatePointerDown(event) {
  event.stopPropagation()
  startRotate(event)
}

let scaleStart = null
const startScale = usePointerDrag({
  onStart({ event }) {
    const c = itemCenterClient()
    scaleStart = {
      dist: Math.hypot(event.clientX - c.x, event.clientY - c.y),
      scale: props.item.scale
    }
  },
  onMove({ event }) {
    if (!scaleStart) return
    const c = itemCenterClient()
    const dist = Math.hypot(event.clientX - c.x, event.clientY - c.y)
    const factor = dist / Math.max(1, scaleStart.dist)

    lightTable.transformItem(props.item.id, {
      scale: Math.max(0.05, scaleStart.scale * factor)
    })
  },
  onEnd() {
    scaleStart = null
  }
})

function onScalePointerDown(event) {
  event.stopPropagation()
  startScale(event)
}

const editingLabel = ref(false)
const labelDraft = ref('')
const labelInputEl = ref(null)

function startLabelEdit() {
  if (props.readonly) return
  labelDraft.value = props.item.label
  editingLabel.value = true
  nextTick(() => {
    labelInputEl.value?.focus()
    labelInputEl.value?.select()
  })
}

function commitLabel() {
  if (!editingLabel.value) return
  lightTable.setLabel(props.item.id, labelDraft.value)
  editingLabel.value = false
}

watch(lightTable.editRequest, (request) => {
  if (request?.kind === 'item' && request.id === props.item.id) {
    lightTable.editRequest.value = null
    startLabelEdit()
  }
})

function cancelLabel() {
  editingLabel.value = false
}

function onImgLoad(e) {
  if (props.item.loaded) return
  const size = fitSize(
    e.target.naturalWidth,
    e.target.naturalHeight,
    MAX_ITEM_WIDTH
  )

  if (size) lightTable.setItemSize(props.item.id, size.w, size.h)
}
</script>

<style scoped>
.lt-item {
  position: absolute;
  left: 0;
  top: 0;
  user-select: none;
  touch-action: none;
  cursor: grab;
  background: var(--bg-foreground);
  box-shadow: var(--panel-shadow);
}

.lt-item:active {
  cursor: grabbing;
}

.lt-item--selected {
  outline: 2px solid var(--lt-selection, var(--color-primary));
  outline-offset: 2px;
}

.lt-item__media {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: contain;
  pointer-events: none;
}

.lt-handle {
  position: absolute;
  z-index: 1;
  box-sizing: border-box;
  width: 12px;
  height: 12px;
  background: var(--bg-foreground);
  border: 2px solid var(--lt-selection, var(--color-primary));
  border-radius: 2px;
}

.lt-handle--scale {
  cursor: nwse-resize;
}

.lt-handle--tl {
  left: -6px;
  top: -6px;
}

.lt-handle--tr {
  right: -6px;
  top: -6px;
  cursor: nesw-resize;
}

.lt-handle--bl {
  left: -6px;
  bottom: -6px;
  cursor: nesw-resize;
}

.lt-handle--br {
  right: -6px;
  bottom: -6px;
}

.lt-handle--rotate {
  left: 50%;
  top: -28px;
  transform: translateX(-50%);
  border-radius: 50%;
  cursor: alias;
}

.lt-handle--rotate::before {
  content: '';
  position: absolute;
  left: 50%;
  top: 100%;
  width: 1px;
  height: 16px;
  background: var(--lt-selection, var(--color-primary));
}

.lt-item__label {
  position: absolute;
  top: 100%;
  left: 50%;
  max-width: 90%;
  margin-top: 8px;
  padding: 3px 8px;
  transform: translateX(-50%);
  font-size: var(--font-size-xs);
  line-height: 1.2;
  white-space: nowrap;
  color: var(--tooltip-text-color);
  background: var(--tooltip-bg-color);
  border-radius: var(--border-radius-xsmall);
  user-select: text;
  cursor: text;
}

.lt-item__label--empty {
  color: var(--text-muted-color);
  background: transparent;
  border: 1px dashed currentColor;
  font-style: italic;
}

.lt-item__label-text {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
}

.lt-item__label-input {
  box-sizing: border-box;
  width: 100%;
  min-width: 80px;
  margin: 0;
  padding: 0;
  font: inherit;
  color: inherit;
  background: transparent;
  border: none;
  outline: none;
}
</style>
