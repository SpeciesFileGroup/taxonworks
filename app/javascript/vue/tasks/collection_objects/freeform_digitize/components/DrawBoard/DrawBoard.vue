<template>
  <div
    class="svg-editor panel"
    ref="elementBoard"
  />
</template>

<script setup>
import { nextTick, onMounted, ref } from 'vue'
import useStore from '../../store/board.js'

const props = defineProps({
  image: {
    type: Object,
    required: true
  }
})

const store = useStore()
const elementBoard = ref(null)

onMounted(() => {
  const size = elementBoard.value.getBoundingClientRect()
  const containerHeight = window.innerHeight - 250
  const width = parseInt(size.width, 10)
  const height = containerHeight

  store.createSVGBoard({
    element: elementBoard.value,
    opts: {
      imageSrc: props.image.original_png,
      ...store.opts,
      width: width,
      height: height
    }
  })

  nextTick(() => {
    const svg = elementBoard.value.querySelector('svg')

    svg.setAttribute('width', '100%')
    svg.setAttribute('height', '100%')
  })
})
</script>

<style scoped>
.svg-editor {
  width: 100%;
  height: calc(100vh - 160px);
}
</style>
