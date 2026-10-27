<template>
  <component
    :is="tag"
    ref="reference"
    v-bind="$attrs"
    @mouseenter="show"
    @mouseleave="hide"
    @focusin="show"
    @focusout="hide"
  >
    <slot />

    <Teleport to="body">
      <div
        v-if="isMounted"
        ref="floating"
        :class="['tw-tooltip', tooltipClass]"
        role="tooltip"
        :data-placement="side"
        :data-show="isVisible ? '' : null"
        :style="floatingStyles"
      >
        <div class="tw-tooltip__content">
          <slot name="content">{{ content }}</slot>
        </div>
        <div
          v-if="arrow"
          ref="floatingArrow"
          class="tw-tooltip__arrow"
          :style="arrowStyle"
        />
      </div>
    </Teleport>
  </component>
</template>

<script setup>
import { ref, computed, nextTick, onBeforeUnmount, useSlots } from 'vue'
import {
  useFloating,
  offset,
  flip,
  shift,
  arrow as arrowMiddleware,
  autoUpdate
} from '@floating-ui/vue'

const ARROW_SIZE = 8
const OFFSET = 8
const HIDE_DELAY = 150

const STATIC_SIDE = {
  top: 'bottom',
  right: 'left',
  bottom: 'top',
  left: 'right'
}

defineOptions({
  inheritAttrs: false
})

const props = defineProps({
  content: {
    type: String,
    default: ''
  },

  placement: {
    type: String,
    default: 'bottom'
  },

  disabled: {
    type: Boolean,
    default: false
  },

  arrow: {
    type: Boolean,
    default: true
  },

  tag: {
    type: String,
    default: 'span'
  },

  tooltipClass: {
    type: [String, Array, Object],
    default: ''
  }
})

const slots = useSlots()

const reference = ref(null)
const floating = ref(null)
const floatingArrow = ref(null)

const isMounted = ref(false)
const isVisible = ref(false)
let hideTimer = null

const hasContent = computed(() => !!props.content || !!slots.content)

const { floatingStyles, middlewareData, placement } = useFloating(
  reference,
  floating,
  {
    placement: computed(() => props.placement),
    transform: false,
    whileElementsMounted: autoUpdate,
    middleware: computed(() => [
      offset(OFFSET),
      flip(),
      shift({ padding: 5 }),
      ...(props.arrow ? [arrowMiddleware({ element: floatingArrow })] : [])
    ])
  }
)

const side = computed(() => placement.value.split('-')[0])

const arrowStyle = computed(() => {
  const data = middlewareData.value.arrow

  if (!data) return {}

  return {
    left: data.x != null ? `${data.x}px` : '',
    top: data.y != null ? `${data.y}px` : '',
    [STATIC_SIDE[side.value]]: `${-ARROW_SIZE / 2}px`
  }
})

function show() {
  if (props.disabled || !hasContent.value) return

  clearTimeout(hideTimer)
  hideTimer = null
  isMounted.value = true

  nextTick(() => {
    requestAnimationFrame(() => {
      if (isMounted.value) isVisible.value = true
    })
  })
}

function hide() {
  isVisible.value = false
  hideTimer = setTimeout(() => {
    isMounted.value = false
  }, HIDE_DELAY)
}

onBeforeUnmount(() => clearTimeout(hideTimer))
</script>
