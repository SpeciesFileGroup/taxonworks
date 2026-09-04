<template>
  <Transition name="modal">
    <div
      v-if="isVisible"
      ref="modalMask"
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
                icon
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
const modalMask = ref(null)

const handleKeys = (e) => {
  if (e.key === 'Escape') {
    e.stopPropagation()
    emit('close')
  }
}

// Modals are frequently teleported to <body>. Turbolinks snapshots <body>
// synchronously when caching a page, so a modal left open while navigating away
// (e.g. following a task link from the radial navigator's "All tasks" list)
// would be restored on "Back" as dead markup no component controls. Detach it
// synchronously before the snapshot is taken.
const handleBeforeCache = () => {
  emit('close')
  modalMask.value?.remove()
  // onMounted's `overflow: hidden` scroll lock is an inline style on <body>, so
  // it rides into the cached snapshot too; clear it unconditionally (every modal
  // on this page dies in the navigation) or "Back" restores an unscrollable page.
  document.body.style.removeProperty('overflow')
}

onMounted(() => {
  isVisible.value = true
  listenerId = ModalEventStack.addListener(handleKeys, {
    atStart: true,
    stopPropagation: true
  })

  document.addEventListener('turbolinks:before-cache', handleBeforeCache)
  document.body.style.setProperty('overflow', 'hidden')
})
onUnmounted(() => {
  ModalEventStack.removeListener(listenerId)
  document.removeEventListener('turbolinks:before-cache', handleBeforeCache)

  if (ModalEventStack.isEmpty()) {
    document.body.style.removeProperty('overflow')
  }
})
</script>
