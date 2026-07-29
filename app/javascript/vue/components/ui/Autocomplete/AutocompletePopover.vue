<template>
  <VPopover
    ref="popoverRef"
    :placement="placement"
    :offset="offset"
    :auto-flip="autoFlip"
    :width="panelWidth"
    :disabled="disabled"
    :ignore-selectors="IGNORED_OUTSIDE_SELECTORS"
    @open="onOpen"
    @close="emit('close')"
    @reposition="autocompleteRef?.hiddenList()"
  >
    <template #trigger="{ triggerAttributes }">
      <VBtn
        v-bind="mergeProps(triggerAttributes, sizeAttributes, buttonProps)"
        :color="color"
        :variant="variant"
        :circle="circle"
        :icon="icon || isIconOnly"
        :title="title"
        :disabled="disabled"
      >
        <slot name="button">
          <IconSearch :class="iconSizeClass" />
          <template v-if="buttonLabel">{{ buttonLabel }}</template>
        </slot>
      </VBtn>
    </template>

    <template #default="{ close }">
      <div class="tw-autocomplete-popover">
        <div
          v-if="$slots.left"
          class="tw-autocomplete-popover__aside"
        >
          <slot
            name="left"
            :close="close"
          />
        </div>

        <div class="tw-autocomplete-popover__main">
          <slot
            name="top"
            :close="close"
          />

          <Autocomplete
            ref="autocompleteRef"
            v-bind="$attrs"
            @select="onSelect"
          />

          <slot
            name="bottom"
            :close="close"
          />
        </div>

        <div
          v-if="$slots.right"
          class="tw-autocomplete-popover__aside"
        >
          <slot
            name="right"
            :close="close"
          />
        </div>
      </div>
    </template>
  </VPopover>
</template>

<script setup>
import { computed, mergeProps, nextTick, ref, useSlots } from 'vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconSearch from '@/components/Icon/IconSearch.vue'
import VPopover from '@/components/ui/VPopover/VPopover.vue'
import { PLACEMENTS } from '@/components/ui/VPopover/constants'
import { useSizes, sizeProps } from '@/composables'

const IGNORED_OUTSIDE_SELECTORS = ['.vue-autocomplete-list']
const SMALL_SIZES = ['xxSmall', 'xSmall', 'small']

defineOptions({
  name: 'AutocompletePopover',
  inheritAttrs: false
})

const props = defineProps({
  ...sizeProps,

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

  panelWidth: {
    type: String,
    default: '280px'
  },

  closeOnSelect: {
    type: Boolean,
    default: true
  },

  autofocus: {
    type: Boolean,
    default: true
  },

  disabled: {
    type: Boolean,
    default: false
  },

  buttonLabel: {
    type: String,
    default: ''
  },

  buttonProps: {
    type: Object,
    default: () => ({})
  },

  color: {
    type: String,
    default: 'primary'
  },

  variant: {
    type: String,
    default: 'solid'
  },

  circle: {
    type: Boolean,
    default: false
  },

  icon: {
    type: Boolean,
    default: false
  },

  // Tooltip and aria-label of the trigger: with an icon-only button this is the
  // only description of what the button does.
  title: {
    type: String,
    default: 'Search'
  }
})

const emit = defineEmits(['select', 'open', 'close'])

const slots = useSlots()

const popoverRef = ref(null)
const autocompleteRef = ref(null)
const isIconOnly = computed(() => !props.buttonLabel && !slots.button)

const { explicitSize } = useSizes(props)

// VBtn takes its size as a boolean prop (small, large, ...); forward whichever
// one is set so the trigger can be sized without reaching for buttonProps.
const sizeAttributes = computed(() =>
  explicitSize.value ? { [explicitSize.value]: true } : {}
)

// The default icon would overflow the smaller trigger sizes (xSmall is 16px).
const iconSizeClass = computed(() =>
  SMALL_SIZES.includes(explicitSize.value) ? 'w-3 h-3' : 'w-4 h-4'
)

async function onOpen() {
  emit('open')

  if (!props.autofocus) return

  await nextTick()

  requestAnimationFrame(() => autocompleteRef.value?.setFocus())
}

function onSelect(item) {
  emit('select', item)

  if (props.closeOnSelect) {
    popoverRef.value?.close()
  }
}

defineExpose({
  open: () => popoverRef.value?.open(),
  close: () => popoverRef.value?.close(),
  toggle: () => popoverRef.value?.toggle(),
  focus: () => autocompleteRef.value?.setFocus(),
  clear: () => autocompleteRef.value?.cleanInput()
})
</script>
