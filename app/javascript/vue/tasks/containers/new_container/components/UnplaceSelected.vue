<template>
  <VBtn
    color="primary"
    @click="store.unplaceSelected"
  >
    Unplace selected
  </VBtn>
</template>

<script setup>
import { useContainerStore } from '../store'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useContainerStore()
</script>
