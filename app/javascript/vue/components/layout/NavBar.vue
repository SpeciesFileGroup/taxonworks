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
import { computed, ref, watch, onMounted } from 'vue'
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
    default: '.fixed_header_bar'
  }
})

const windowSize = useWindowSize()
const scroll = useScroll(window)
const navbar = ref(null)
const width = ref(null)
const height = ref('auto')
const position = ref(null)
const isFixed = ref(false)
const resolvedOffset = ref(0)

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

const updateOffset = () => {
  if (props.topOffset !== null) {
    resolvedOffset.value = props.topOffset
  } else {
    const element = getReferenceElement()
    resolvedOffset.value = element ? element.offsetHeight : 0
  }
}

const setFixeable = () => {
  isFixed.value = scroll.y.value + resolvedOffset.value > position.value
  width.value = `${navbar.value.parentElement.clientWidth}px`
}

watch([scroll.y, windowSize.width], () => {
  updateOffset()
  props.scrollFix && setFixeable()
  height.value = `${navbar.value.clientHeight}px`
})

onMounted(() => {
  position.value = navbar.value.offsetTop
  updateOffset()
})
</script>

<style lang="scss" scoped>
.navbar-fixed-top {
  z-index: 1001;
  position: fixed;
  box-sizing: border-box;
}
</style>
