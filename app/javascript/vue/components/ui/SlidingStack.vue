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
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

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
  }
})

const viewportRef = ref(null)
const viewportWidth = ref(0)
const stack = ref([])
const depth = computed(() => stack.value.length)

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
  stack.value.push({ id: uniqueId(), payload })
}

function pop() {
  stack.value.pop()
}

function popToRoot() {
  stack.value = []
}

function replace(payload) {
  if (stack.value.length) {
    stack.value[stack.value.length - 1] = { id: uniqueId(), payload }
  }
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
