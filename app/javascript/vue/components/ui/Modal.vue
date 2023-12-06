<template>
  <transition name="modal">
    <div
      class="modal-mask"
      @click="emit('close')"
      @key.esc.stop="emit('close')"
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
          <div
            class="modal-header"
            :class="{ 'panel content': transparent }"
          >
            <slot name="header"> default header </slot>
          </div>
          <div class="modal-body">
            <slot name="body"> default body </slot>
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
import { ModalEventStack } from '@/utils'

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

let listenerId

const emit = defineEmits(['close'])

const handleKeys = (e) => {
  if (e.key === 'Escape') {
    e.stopPropagation()
    emit('close')
  }
}

onMounted(() => {
  listenerId = ModalEventStack.addListener(handleKeys, {
    atStart: true,
    stopPropagation: true
  })
})
onUnmounted(() => {
  ModalEventStack.removeListener(listenerId)
})
</script>
