<template>
  <div
    ref="elementBoard"
    :data-height="600"
    :data-width="600"
    :data-image="image.image_file_url"
  />
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../../store/actions/actions'

const store = useStore()
const elementBoard = ref(null)

defineProps({
  image: {
    type: Object,
    required: true
  }
})

onMounted(() => {
  store.dispatch(ActionNames.CreateSVGBoard, elementBoard.value)
})
</script>
