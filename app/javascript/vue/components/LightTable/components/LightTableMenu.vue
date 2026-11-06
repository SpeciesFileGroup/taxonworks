<template>
  <ContextMenu
    ref="contextMenuRef"
    class="lt-menu"
  >
    <slot />
  </ContextMenu>
</template>

<script setup>
import { ref } from 'vue'
import ContextMenu from '@/components/ui/Context/ContextMenu.vue'

const contextMenuRef = ref(null)

function openAt({ x, y }) {
  contextMenuRef.value.openContextMenu({ x, y })
}

function openBelow(element) {
  const { left, bottom } = element.getBoundingClientRect()

  openAt({ x: left, y: bottom })
}

defineExpose({ openAt, openBelow })
</script>

<style scoped>
.lt-menu {
  z-index: 1000;
  width: auto;
  min-width: 220px;
  overflow: visible;
  border-radius: var(--border-radius-small);
}
</style>
