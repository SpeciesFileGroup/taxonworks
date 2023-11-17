<template>
  <div ref="elementBoard" />
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
  store.createSVGBoard({
    element: elementBoard.value,
    opts: {
      imageSrc: props.image.image_file_url,
      width: 600,
      height: 600
    }
  })
})
</script>
