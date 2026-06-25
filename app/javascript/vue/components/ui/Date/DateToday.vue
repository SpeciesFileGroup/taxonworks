<template>
  <VBtn
    color="primary"
    medium
    variant="tonal"
    @click="emitActualDate"
  >
    Today
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['update:day', 'update:month', 'update:year'])

const emitActualDate = () => {
  const today = new Date()

  emit('update:day', today.getDate())
  emit('update:month', today.getMonth() + 1)
  emit('update:year', today.getFullYear())
}
</script>
