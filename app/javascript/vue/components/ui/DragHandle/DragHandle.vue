<template>
  <span
    class="handle drag-handle"
    :class="color !== 'muted' && `drag-handle--${color}`"
    v-tooltip="tooltipText"
    :aria-label="tooltipText"
    role="button"
  >
    <IconGripVertical class="w-4 h-4" />
  </span>
</template>

<script setup>
import IconGripVertical from '@/components/Icon/IconGripVertical.vue'
import { vTooltip } from '@/directives'
import { computed } from 'vue'

defineOptions({ name: 'DragHandle' })

const props = defineProps({
  label: {
    type: String,
    default: undefined
  },

  tooltip: {
    type: String,
    default: undefined
  },

  color: {
    type: String,
    default: 'muted',
    validator: (value) => ['muted', 'primary', 'create'].includes(value)
  }
})

const tooltipText = computed(
  () =>
    props.tooltip ??
    ['Press and hold to drag', props.label].filter(Boolean).join(' ')
)
</script>
