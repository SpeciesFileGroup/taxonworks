<template>
  <div
    ref="viewportRef"
    class="sliding-stack__viewport"
  >
    <div
      class="sliding-stack__slider"
      :style="sliderStyle"
      @pointerdown="onPointerDown"
      @pointermove="onPointerMove"
      @pointerup="onPointerUp"
    >
      <div
        ref="masterPanelRef"
        class="sliding-stack__panel sliding-stack__panel--master"
        :style="panelStyle"
      >
        <slot
          name="master"
          :push="push"
        />
      </div>

      <div
        v-for="(entry, index) in stack"
        :key="entry.id"
        :ref="(el) => setDetailRef(el, index)"
        class="sliding-stack__panel sliding-stack__panel--detail"
        :style="panelStyle"
      >
        <slot
          name="detail"
          :payload="entry.payload"
          :push="push"
          :pop="pop"
          :pop-to-root="popToRoot"
          :replace="replace"
          :depth="index + 1"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'

let uid = 0

function uniqueId() {
  return `ss-${++uid}`
}

const props = defineProps({
  animationDuration: {
    type: Number,
    default: 300
  },

  swipeEnabled: {
    type: Boolean,
    default: true
  },

  scrollOffset: {
    type: Number,
    default: 0
  },

  scrollOffsetElement: {
    type: [HTMLElement, String],
    default: null
  }
})

const viewportRef = ref(null)
const masterPanelRef = ref(null)
const detailPanelRefs = {}
const viewportWidth = ref(0)
const stack = ref([])
const depth = computed(() => stack.value.length)

const scrollStateMap = new Map()

let resizeObserver = null

onMounted(() => {
  if (viewportRef.value) {
    viewportWidth.value = viewportRef.value.offsetWidth
    resizeObserver = new ResizeObserver(([entry]) => {
      viewportWidth.value = entry.contentRect.width
    })
    resizeObserver.observe(viewportRef.value)
  }
})

onBeforeUnmount(() => {
  resizeObserver?.disconnect()
})

function setDetailRef(el, index) {
  if (el) {
    detailPanelRefs[index] = el
  } else {
    delete detailPanelRefs[index]
  }
}

function getPanelElement(level) {
  return level === 0
    ? masterPanelRef.value
    : (detailPanelRefs[level - 1] ?? null)
}

function saveScrollState(level) {
  const panelEl = getPanelElement(level)
  const elements = []

  if (panelEl) {
    for (const el of panelEl.querySelectorAll('*')) {
      if (el.scrollTop !== 0 || el.scrollLeft !== 0) {
        elements.push({
          el,
          scrollTop: el.scrollTop,
          scrollLeft: el.scrollLeft
        })
      }
    }
  }

  scrollStateMap.set(level, {
    elements,
    windowX: window.scrollX,
    windowY: window.scrollY
  })
}

function restoreScrollState(level) {
  const state = scrollStateMap.get(level)
  if (!state) return

  for (const { el, scrollTop, scrollLeft } of state.elements) {
    el.scrollTop = scrollTop
    el.scrollLeft = scrollLeft
  }

  window.scrollTo(state.windowX, state.windowY)
}

const panelStyle = computed(() => ({
  width: `${viewportWidth.value}px`,
  flexShrink: '0',
  minWidth: '0'
}))

const sliderStyle = computed(() => ({
  transform: `translateX(-${depth.value * viewportWidth.value}px)`,
  transition: `transform ${props.animationDuration}ms ease`,
  willChange: 'transform'
}))

function push(payload) {
  saveScrollState(depth.value)

  stack.value.push({
    id: uniqueId(),
    payload
  })

  nextTick(scrollViewportToTop)
}

function scrollViewportToTop() {
  const viewport = viewportRef.value
  if (!viewport) return

  const offset = getScrollOffset()
  const viewportTop = getElementAbsoluteTop(viewport)

  window.scrollTo({
    top: viewportTop - offset,
    behavior: 'auto'
  })
}

function getScrollOffset() {
  const baseOffset = props.scrollOffset ?? 0
  const elementOffset = getOffsetElementHeight()

  return baseOffset + elementOffset
}

function getOffsetElementHeight() {
  const offsetSource = resolveOffsetElement()
  if (!offsetSource) return 0

  const rect = offsetSource.getBoundingClientRect()

  if (rect.height) {
    return rect.top + rect.height
  }

  return offsetSource.offsetHeight ?? 0
}

function resolveOffsetElement() {
  const source = props.scrollOffsetElement

  if (!source) return null

  if (typeof source === 'string') {
    return document.querySelector(source)
  }

  return source
}

function getElementAbsoluteTop(element) {
  const rect = element.getBoundingClientRect()
  return rect.top + window.scrollY
}

function pop() {
  if (depth.value === 0) return

  const targetLevel = depth.value - 1

  stack.value.pop()

  nextTick(() => {
    restoreScrollState(targetLevel)
  })
}

function popToRoot() {
  if (depth.value === 0) return

  stack.value = []

  nextTick(() => {
    restoreScrollState(0)
  })
}

function replace(payload) {
  if (!stack.value.length) return

  stack.value[stack.value.length - 1] = { id: uniqueId(), payload }
}

let pointerStartX = null
let pointerStartY = null
let isHorizontalSwipe = null

function onPointerDown(event) {
  if (!props.swipeEnabled) return
  pointerStartX = event.clientX
  pointerStartY = event.clientY
  isHorizontalSwipe = null
}

function onPointerMove(event) {
  if (!props.swipeEnabled || pointerStartX === null) return
  const deltaX = event.clientX - pointerStartX
  const deltaY = event.clientY - pointerStartY

  if (isHorizontalSwipe === null) {
    isHorizontalSwipe = Math.abs(deltaX) > Math.abs(deltaY)
  }
}

function onPointerUp(event) {
  if (!props.swipeEnabled || pointerStartX === null) return
  const deltaX = event.clientX - pointerStartX

  if (isHorizontalSwipe && deltaX > 50 && depth.value > 0) {
    pop()
  }

  pointerStartX = null
  pointerStartY = null
  isHorizontalSwipe = null
}

defineExpose({ push, pop, popToRoot, replace })
</script>

<style scoped>
.sliding-stack__viewport {
  overflow: hidden;
  width: 100%;
}

.sliding-stack__slider {
  display: flex;
  will-change: transform;
}

.sliding-stack__panel {
  flex-shrink: 0;
  min-width: 0;
}
</style>
