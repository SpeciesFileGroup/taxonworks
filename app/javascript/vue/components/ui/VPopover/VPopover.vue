<template>
  <span
    ref="referenceRef"
    class="tw-popover__reference"
    @click="toggle"
  >
    <slot
      name="trigger"
      :is-open="isOpen"
      :open="open"
      :close="close"
      :toggle="toggle"
      :trigger-attributes="triggerAttributes"
    />
  </span>

  <Teleport
    to="body"
    :disabled="!teleport"
  >
    <Transition name="tw-popover">
      <div
        v-if="isOpen"
        :id="panelId"
        ref="floatingRef"
        class="tw-popover"
        role="dialog"
        :data-placement="side"
        :style="[floatingStyles, panelStyle]"
      >
        <slot
          :is-open="isOpen"
          :close="close"
        />
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { computed, ref, useId, watch } from 'vue'
import {
  useFloating,
  offset as offsetMiddleware,
  flip,
  shift,
  autoUpdate
} from '@floating-ui/vue'
import { useClickOutside, useEventListener } from '@/composables'
import { PLACEMENTS } from './constants'

const FOCUSABLE_SELECTOR =
  'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'

defineOptions({ name: 'VPopover' })

const props = defineProps({
  placement: {
    type: String,
    default: 'bottom-start',
    validator: (value) => PLACEMENTS.includes(value)
  },

  offset: {
    type: Number,
    default: 8
  },

  autoFlip: {
    type: Boolean,
    default: true
  },

  closeOnEsc: {
    type: Boolean,
    default: true
  },

  closeOnOutside: {
    type: Boolean,
    default: true
  },

  disabled: {
    type: Boolean,
    default: false
  },

  teleport: {
    type: Boolean,
    default: true
  },

  width: {
    type: String,
    default: undefined
  },

  ignoreSelectors: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['open', 'close', 'reposition'])

const panelId = useId()

const referenceRef = ref(null)
const floatingRef = ref(null)
const isOpen = ref(false)

const { floatingStyles, placement, x, y } = useFloating(
  referenceRef,
  floatingRef,
  {
    placement: computed(() => props.placement),
    transform: false,
    whileElementsMounted: autoUpdate,
    middleware: computed(() => [
      offsetMiddleware(props.offset),
      ...(props.autoFlip ? [flip(), shift({ padding: 8 })] : [])
    ])
  }
)

const side = computed(() => placement.value.split('-')[0])

const panelStyle = computed(() => ({ width: props.width }))

const triggerAttributes = computed(() => ({
  'aria-haspopup': 'dialog',
  'aria-expanded': String(isOpen.value),
  'aria-controls': isOpen.value ? panelId : undefined
}))

watch([x, y], () => {
  if (isOpen.value) emit('reposition')
})

useClickOutside([referenceRef, floatingRef], (event) => {
  if (!props.closeOnOutside || isIgnoredTarget(event.target)) return

  close()
})

useEventListener(document, 'keydown', (event) => {
  if (!isOpen.value || !props.closeOnEsc || event.key !== 'Escape') return

  close()
  focusTrigger()
})

function open() {
  if (props.disabled || isOpen.value) return

  isOpen.value = true
  emit('open')
}

function close() {
  if (!isOpen.value) return

  isOpen.value = false
  emit('close')
}

function toggle() {
  isOpen.value ? close() : open()
}

function isIgnoredTarget(target) {
  return props.ignoreSelectors.some((selector) => target?.closest?.(selector))
}

function focusTrigger() {
  referenceRef.value?.querySelector(FOCUSABLE_SELECTOR)?.focus()
}

defineExpose({
  open,
  close,
  toggle,
  isOpen: computed(() => isOpen.value)
})
</script>
