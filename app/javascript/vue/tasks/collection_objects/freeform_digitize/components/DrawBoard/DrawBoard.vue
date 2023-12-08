<template>
  <div
    ref="elementBoard"
    class="panel"
  />
</template>

<script setup>
import { onMounted, ref } from 'vue'
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

  console.log(height)

  store.createSVGBoard({
    element: elementBoard.value,
    opts: {
      imageSrc: props.image.image_file_url,
      stroke: '#FFA500',
      strokeWidth: 2,
      width,
      height
    }
  })
})
</script>
