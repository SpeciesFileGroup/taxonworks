<template>
  <div
    class="panel popup"
    ref="element"
  >
    <div class="content">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'

const emit = defineEmits(['close'])

const element = ref()

function handleEvent(event) {
  if (!event.target || !element.value?.contains(event.target)) {
    emit('close')
  }
}

onMounted(() => {
  document.addEventListener('pointerdown', handleEvent, {
    passive: true,
    capture: true
  })
})

onBeforeUnmount(() => {
  document.removeEventListener('pointerdown', handleEvent, {
    capture: true
  })
})
</script>

<style scoped>
.popup {
  position: absolute;
  z-index: 1000;
}
</style>
