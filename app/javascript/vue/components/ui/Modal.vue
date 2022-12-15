<template>
  <transition name="modal">
    <div
      class="modal-mask"
      @click="emit('close')"
      @key.esc="emit('close')"
    >
      <div class="modal-wrapper">
        <div
          class="modal-container"
          :class="{
            'bg-transparent shadow-none': transparent,
            ...containerClass
          }"
          :style="containerStyle"
          @click.stop
        >
          <div class="modal-header">
            <div
              class="modal-close"
              :class="{ 'invert-color opacity-100': transparent }"
              @click="emit('close')"
            />
            <slot name="header">
              default header
            </slot>
          </div>
          <div class="modal-body">
            <slot name="body">
              default body
            </slot>
          </div>
          <div class="modal-footer">
            <slot name="footer" />
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'

defineProps({
  containerClass: {
    type: Object,
    default: () => ({})
  },

  containerStyle: {
    type: Object,
    default: () => ({})
  },

  transparent: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

const handleKeys = (e) => {
  if (e.key === 'Escape') {
    emit('close')
  }
}

onMounted(() => { document.addEventListener('keydown', handleKeys) })
onUnmounted(() => { document.removeEventListener('keydown', handleKeys) })
</script>
