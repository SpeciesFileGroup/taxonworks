<template>
  <div
    class="lt-submenu"
    @mouseenter="open"
    @mouseleave="isOpen = false"
    @focusout="onFocusOut"
  >
    <LightTableMenuItem
      :label="label"
      shortcut="›"
      :disabled="disabled"
      aria-haspopup="menu"
      :aria-expanded="isOpen"
      @click="onTriggerClick"
      @keydown.right.prevent="open"
      @keydown.left.prevent="isOpen = false"
    />
    <div
      v-if="isOpen"
      ref="panelRef"
      class="lt-submenu__panel"
      :class="{ 'lt-submenu__panel--left': isFlipped }"
      role="menu"
    >
      <slot />
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick } from 'vue'
import LightTableMenuItem from './LightTableMenuItem.vue'

const props = defineProps({
  label: {
    type: String,
    required: true
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const isOpen = ref(false)
const isFlipped = ref(false)
const panelRef = ref(null)

async function open() {
  if (props.disabled || isOpen.value) return

  isFlipped.value = false
  isOpen.value = true
  await nextTick()

  const rect = panelRef.value?.getBoundingClientRect()
  isFlipped.value = !!rect && rect.right > window.innerWidth
}

function onTriggerClick(event) {
  event.stopPropagation()
  open()
}

function onFocusOut(event) {
  if (!event.currentTarget.contains(event.relatedTarget)) {
    isOpen.value = false
  }
}
</script>

<style scoped>
.lt-submenu {
  position: relative;
}

.lt-submenu__panel {
  position: absolute;
  top: calc(-1 * var(--spacing-xxs));
  left: 100%;
  z-index: 1;
  min-width: 200px;
  padding: var(--spacing-xxs) 0;
  background-color: var(--panel-bg-color);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-small);
  box-shadow: var(--panel-shadow);
}

.lt-submenu__panel--left {
  left: auto;
  right: 100%;
}
</style>
