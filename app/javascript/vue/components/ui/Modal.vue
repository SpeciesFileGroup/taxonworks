<template>
  <Transition name="modal">
    <div
      v-if="isVisible"
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
  </Transition>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
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

const isVisible = ref(false)

const handleKeys = (e) => {
  if (e.key === 'Escape') {
    e.stopPropagation()
    emit('close')
  }
}

onMounted(() => {
  isVisible.value = true
  listenerId = ModalEventStack.addListener(handleKeys, {
    atStart: true,
    stopPropagation: true
  })
})
onUnmounted(() => {
  ModalEventStack.removeListener(listenerId)
})
</script>
