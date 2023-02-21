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

<style lang="scss" scoped>
.graph-context-menu {
  display: flex;
  flex-direction: column;
  width: 220px;
  background-color: white;
  padding: 10px;
  position: fixed;
  font-size: 12px;
  border: 1px solid #aaa;
  box-shadow: 2px 2px 2px #aaa;
}
</style>
