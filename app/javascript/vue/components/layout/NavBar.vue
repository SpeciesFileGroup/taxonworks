<template>
  <div
    class="separate-bottom"
    :style="barStyle"
    :class="{ 'navbar-fixed-top': scrollFix && isFixed }"
    ref="navbar"
  >
    <div class="panel">
      <div class="content">
        <slot />
      </div>
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
  }
})

const windowSize = useWindowSize()
const scroll = useScroll(window)
const navbar = ref(null)
const width = ref(null)
const position = ref(null)
const isFixed = ref(false)

const barStyle = computed(() => isFixed.value
  ? {
      width: width.value,
      ...props.componentStyle
    }
  : {}
)

watch([scroll.y, windowSize.width], _ => { props.scrollFix && setFixeable() })

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
    top:0px;
    z-index:1001;
    position: fixed;
  }
</style>
