<template>
  <div ref="elementBoard" />
</template>

<script setup>
import { onMounted, ref } from 'vue'
import useStore from '../../store/board.js'
import useImageStore from '../../store/image'

const props = defineProps({
  image: {
    type: Object,
    required: true
  }
})

const store = useStore()
const imageStore = useImageStore()
const elementBoard = ref(null)

onMounted(() => {
  const size = elementBoard.value.getBoundingClientRect()
  const imageWidth = imageStore.image.width
  const imageHeight = imageStore.image.height
  const containerHeight = window.innerHeight - 250

  const width = imageWidth > size.width ? parseInt(size.width, 10) : imageWidth
  const height = imageHeight > containerHeight ? containerHeight : imageHeight

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
