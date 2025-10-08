<template>
  <div
    v-if="isVisible"
    ref="element"
    class="graph-context-menu panel"
    :style="stylePosition"
    @click="() => (isVisible = false)"
  >
    <slot />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { hasModalInEventPath } from '@vanilla/utils'

const position = ref({})
const isVisible = ref(false)
const element = ref()

const stylePosition = computed(() => ({
  left: position.value.x + 'px',
  top: position.value.y + 'px'
}))

function openContextMenu({ x, y }) {
  isVisible.value = true
  position.value = { x, y }
}

function handleEvent(e) {
  if (!isVisible.value) return

  // If the click occurred anywhere "in" a modal (including SVG inside it),
  // ignore it so the context menu stays open.
  if (hasModalInEventPath(e)) return

  if (!element.value?.contains(e.target)) {
    isVisible.value = false
  }
}

onMounted(() => {
  document.addEventListener('pointerdown', handleEvent, {
    passive: true,
    capture: true
  })
})

onUnmounted(() => {
  document.removeEventListener('pointerdown', handleEvent, {
    capture: true
  })
})

defineExpose({
  openContextMenu
})
</script>

<style lang="scss">
.graph-context-menu {
  display: flex;
  flex-direction: column;
  width: 260px;
  background-color: var(--panel-bg-color);
  position: fixed;
  font-size: 12px;
  border: 1px solid var(--border-color);
  box-shadow: var(--panel-shadow);
  overflow: hidden;
}

.graph-context-menu-list {
  margin: 0px;
  padding: 0px;
  list-style: none;
}
.graph-context-menu-list li,
.graph-context-menu-list-item {
  cursor: pointer;
  padding: 1em;
  border-bottom: 1px solid var(--border-color);
}

.graph-context-menu-list-header {
  padding: 1em;
  background-color: var(--bg-color);
  border-bottom: 2px solid var(--border-color);
}

.graph-context-menu-list-item:hover {
  background-color: var(--bg-color);
}

.graph-context-menu-list-item:last-child {
  border-bottom: none;
}
</style>
