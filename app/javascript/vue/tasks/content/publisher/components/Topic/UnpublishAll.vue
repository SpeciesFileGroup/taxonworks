<template>
  <VBtn
    color="create"
    medium
    @click="unpublishAll(topicId)"
  >
    Unpublish all
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

const { unpublishAll } = useStore()
</script>
