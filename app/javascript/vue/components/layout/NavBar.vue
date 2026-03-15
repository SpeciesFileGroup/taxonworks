<template>
  <div
    ref="root"
    class="separate-bottom"
    :style="{ minHeight: height }"
  >
    <div
      ref="navbar"
      :class="[scrollFix && isFixed && 'navbar-fixed-top', navbarClass]"
      :style="barStyle"
    >
      <slot />
    </div>
  </div>
</template>

<script setup>
import {
  computed,
  ref,
  watch,
  onMounted,
  onBeforeUnmount,
  useTemplateRef,
  nextTick
} from 'vue'
import { useScroll, useWindowSize } from '@/composables/index.js'

const props = defineProps({
  componentStyle: {
    type: Object,
    default: () => ({})
  },

  scrollFix: {
    type: Boolean,
    default: true
  },

  navbarClass: {
    type: String,
    default: 'panel content'
  },

  topOffset: {
    type: Number,
    default: null
  },

  offsetReference: {
    type: [String, HTMLElement],
    default: '#header-wrapper'
  }
})

const windowSize = useWindowSize()
const scroll = useScroll(window)
const width = ref(null)
const height = ref('auto')
const isFixed = ref(false)
const resolvedOffset = ref(0)
const referenceElement = ref()
const root = useTemplateRef('root')
const navbar = useTemplateRef('navbar')

let resizeObserver
let mutationObserver

const barStyle = computed(() =>
  isFixed.value
    ? {
        width: width.value,
        top: `${resolvedOffset.value}px`,
        ...props.componentStyle
      }
    : {}
)

const getReferenceElement = () => {
  if (props.offsetReference instanceof HTMLElement) {
    return props.offsetReference
  }

  return document.querySelector(props.offsetReference)
}

const getPosition = () => {
  return root.value.getBoundingClientRect().top + window.scrollY
}

const updateOffset = () => {
  if (props.topOffset !== null) {
    resolvedOffset.value = props.topOffset
    return
  }

  const element = getReferenceElement()

  if (!element) {
    resolvedOffset.value = 0
    return
  }

  const isReferenceFixed = getComputedStyle(element).position === 'fixed'
  resolvedOffset.value = isReferenceFixed ? element.offsetHeight : 0
}

const setFixeable = () => {
  const position = getPosition()
  isFixed.value = scroll.y.value + resolvedOffset.value > position
  width.value = `${navbar.value.parentElement.clientWidth}px`
}

const recalculate = () => {
  updateOffset()
  if (props.scrollFix) {
    setFixeable()
  }
  height.value = `${navbar.value.clientHeight}px`
}

const observeReference = () => {
  disconnectObservers()

  const element = referenceElement.value
  if (!element) return

  resizeObserver = new ResizeObserver(() => {
    recalculate()
  })
  resizeObserver.observe(element)

  mutationObserver = new MutationObserver(() => {
    nextTick(() => {
      recalculate()
    })
  })
  mutationObserver.observe(element, {
    attributes: true,
    attributeFilter: ['class', 'style']
  })
}

const disconnectObservers = () => {
  resizeObserver?.disconnect()
  mutationObserver?.disconnect()
}

watch([scroll.y, windowSize.width], recalculate)

watch(
  () => props.offsetReference,
  () => {
    referenceElement.value = getReferenceElement()
    observeReference()
    recalculate()
  }
)

onMounted(() => {
  referenceElement.value = getReferenceElement()
  updateOffset()
  observeReference()
})

onBeforeUnmount(disconnectObservers)
</script>

<style lang="scss" scoped>
.navbar-fixed-top {
  z-index: 1001;
  position: fixed;
  box-sizing: border-box;
}
</style>
