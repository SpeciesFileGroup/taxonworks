<template>
  <VBtn
    color="primary"
    @click="store.unplaceAll"
  >
    Unplace all
  </VBtn>
</template>

<script setup>
import { useContainerStore } from '../store'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useContainerStore()
</script>
