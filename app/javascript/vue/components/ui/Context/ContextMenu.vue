<template>
  <div
    v-if="isVisible"
    ref="element"
    class="vue-context-menu"
    :style="stylePosition"
    @click="() => (isVisible = false)"
  >
    <slot />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'

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
  document.addEventListener('contextmenu', handleEvent, {
    passive: true,
    capture: true
  })
})

onBeforeUnmount(() => {
  document.removeEventListener('pointerdown', handleEvent, {
    capture: true
  })
  document.removeEventListener('contextmenu', handleEvent, {
    capture: true
  })
})

defineExpose({
  openContextMenu
})
</script>

<style lang="scss">
.vue-context-menu {
  display: flex;
  flex-direction: column;
  width: 260px;
  background-color: var(--panel-bg-color);
  position: fixed;
  border: 1px solid var(--border-color);
  box-shadow: var(--panel-shadow);
  overflow: hidden;
}
</style>
