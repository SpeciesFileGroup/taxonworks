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
import { useScroll, useWindowSize } from 'compositions/index.js'

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
  }
})

const windowSize = useWindowSize()
const scroll = useScroll(window)
const navbar = ref(null)
const width = ref(null)
const height = ref('auto')
const position = ref(null)
const isFixed = ref(false)
const root = ref(null)

const barStyle = computed(() =>
  isFixed.value
    ? {
        width: width.value,
        ...props.componentStyle
      }
    : {}
)

watch([scroll.y, windowSize.width], (_) => {
  props.scrollFix && setFixeable()
  height.value = `${navbar.value.clientHeight}px`
})

const setFixeable = () => {
  isFixed.value = scroll.y.value > position.value
  width.value = `${navbar.value.parentElement.clientWidth}px`
}

onMounted(() => {
  position.value = navbar.value.offsetTop
})
</script>

<style lang="scss" scoped>
.navbar-fixed-top {
  top: 0px;
  z-index: 1001;
  position: fixed;
  box-sizing: border-box;
}
</style>
