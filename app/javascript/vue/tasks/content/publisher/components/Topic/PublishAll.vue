<template>
  <VBtn
    color="create"
    medium
    @click="publishAll(topicId)"
  >
    Publish all
  </VBtn>
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import { useStore } from '../../composables/useStore'

defineProps({
  topicId: {
    type: Number,
    required: true
  }
})

const { publishAll } = useStore()

</script>
