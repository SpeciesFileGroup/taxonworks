<template>
  <span
    v-if="disabled"
    class="v-btn-tooltip-wrapper"
    v-tooltip="tooltipOptions"
  >
    <component
      :is="tag"
      v-bind="mergeProps($attrs, buttonAttributes)"
      :type="tag === 'button' ? type : undefined"
      :aria-label="title || undefined"
      @click="emit('click', $event)"
    >
      <slot />
    </component>
  </span>

  <component
    v-else
    :is="tag"
    v-bind="mergeProps($attrs, buttonAttributes)"
    :type="tag === 'button' ? type : undefined"
    :aria-label="title || undefined"
    v-tooltip="tooltipOptions"
    @click="emit('click', $event)"
  >
    <slot />
  </component>
</template>

<script setup>
import { computed, mergeProps } from 'vue'
import { vTooltip } from '@/directives'
import { useSizes, sizeProps } from '@/composables'

defineOptions({ name: 'VBtn', inheritAttrs: false })

const props = defineProps({
  ...sizeProps,

  disabled: {
    type: Boolean,
    default: false
  },

  download: {
    type: [String, Boolean],
    default: undefined
  },

  href: {
    type: String,
    default: undefined
  },

  circle: {
    type: Boolean,
    default: false
  },

  icon: {
    type: Boolean,
    default: false
  },

  bordered: {
    type: Boolean,
    default: false
  },

  variant: {
    type: String,
    default: 'solid',
    validator: (value) => ['solid', 'ghost', 'outline', 'tonal'].includes(value)
  },

  color: {
    type: String,
    default: 'default'
  },

  title: {
    type: String,
    default: ''
  },

  type: {
    type: String,
    default: 'button',
    validator: (value) => ['button', 'submit', 'reset'].includes(value)
  }
})

const emit = defineEmits(['click'])

const { semanticSize } = useSizes(props)

const isLink = computed(() => !!props.href && !props.disabled)

const tag = computed(() => (isLink.value ? 'a' : 'button'))

const buttonSize = computed(() => {
  if (props.circle) return `btn-${semanticSize.value}-circle`
  if (props.icon) return `btn-${semanticSize.value}-icon`

  return `btn-${semanticSize.value}-size`
})

const buttonClasses = computed(() => [
  'button',
  `btn-${props.color}`,
  isLink.value ? 'btn-link' : 'btn',
  buttonSize.value,
  { [`btn-${props.variant}`]: props.variant !== 'solid' },
  { 'btn-bordered': props.bordered }
])

const buttonAttributes = computed(() => ({
  class: buttonClasses.value,
  disabled: props.disabled,
  download: isLink.value ? props.download : undefined,
  href: isLink.value ? props.href : undefined
}))

const tooltipOptions = computed(() => ({
  content: props.title,
  placement: 'bottom'
}))
</script>

<style scoped>
.v-btn-tooltip-wrapper {
  display: inline-flex;
}
</style>
