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

function handleEvent(event) {
  if (!event.target || !element.value?.contains(event.target)) {
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
  background-color: white;
  position: fixed;
  font-size: 12px;
  border: 1px solid #aaa;
  box-shadow: 2px 2px 2px #aaa;
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
  border-bottom: 1px solid #eaeaea;
}

.graph-context-menu-list-header {
  padding: 1em;
  background-color: #f0f0f0;
  border-bottom: 2px solid #eaeaea;
}

.graph-context-menu-list-item:hover {
  background-color: #fafafa;
}

.graph-context-menu-list-item:last-child {
  border-bottom: none;
}
</style>
