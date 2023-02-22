<template>
  <div
    ref="element"
    class="graph-context-menu panel"
  >
    <slot />
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

const props = defineProps({
  position: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['focusout'])
const element = ref()

function handleEvent(event) {
  if (!event.target || !element.value.contains(event.target)) {
    emit('focusout')
  }
}

onMounted(() => {
  element.value.style.left = props.position.x + 'px'
  element.value.style.top = props.position.y + 'px'

  document.addEventListener('pointerdown', handleEvent, {
    passive: true,
    capture: true
  })
})

onUnmounted(() => {
  document.removeEventListener('pointerdown', handleEvent, { capture: true })
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

.graph-context-menu-list-item:hover {
  background-color: #fafafa;
}

.graph-context-menu-list-item:last-child {
  border-bottom: none;
}
</style>
