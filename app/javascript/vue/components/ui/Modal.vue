<template>
  <Transition name="modal">
    <div
      v-if="isVisible"
      class="modal-mask"
      @mousedown="emit('close')"
      @key.esc.stop="emit('close')"
    >
      <div class="modal-wrapper">
        <div
          class="modal-container"
          :class="[
            {
              'bg-transparent shadow-none': transparent
            },
            ...[containerClass].flat()
          ]"
          :style="containerStyle"
          @mousedown.stop
        >
          <div
            class="modal-header"
            :class="{ 'panel content': transparent }"
          >
            <div class="flex-separate middle gap-small">
              <div class="full_width">
                <slot name="header"> default header </slot>
              </div>
              <VBtn
                circle
                color="primary"
                variant="ghost"
                title="Close (escape key)"
                v-bind="buttonClose"
                @click="() => emit('close')"
              >
                <IconClose
                  class="w-4 h-4"
                  title="Close (escape key)"
                />
              </VBtn>
            </div>
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
import VBtn from '@/components/ui/VBtn/index.vue'
import IconClose from '@/components/Icon/IconClose.vue'

defineProps({
  buttonClose: {
    type: Object,
    default: () => ({})
  },

  containerClass: {
    type: [Object, Array],
    default: () => []
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

  document.body.style.setProperty('overflow', 'hidden')
})
onUnmounted(() => {
  ModalEventStack.removeListener(listenerId)

  if (ModalEventStack.isEmpty()) {
    document.body.style.removeProperty('overflow')
  }
})
</script>
