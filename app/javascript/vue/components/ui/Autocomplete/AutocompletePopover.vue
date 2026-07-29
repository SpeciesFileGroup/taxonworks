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
        v-bind="mergeProps(triggerAttributes, buttonProps)"
        :color="color"
        :variant="variant"
        :circle="circle"
        :icon="icon || isIconOnly"
        :title="title"
        :disabled="disabled"
      >
        <slot name="button">
          <IconSearch class="w-4 h-4" />
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

const IGNORED_OUTSIDE_SELECTORS = ['.vue-autocomplete-list']

defineOptions({
  name: 'AutocompletePopover',
  inheritAttrs: false
})

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
