<template>
  <v-btn
    color="primary"
    medium
    @click="emitActualDate"
  >
    Now
  </v-btn>
</template>

<script setup>

import VBtn from 'components/ui/VBtn/index.vue'

const emit = defineEmits([
  'update:day',
  'update:month',
  'update:year'
])

const emitActualDate = () => {
  const today = new Date()

  emit('update:day', today.getDate())
  emit('update:month', today.getMonth() + 1)
  emit('update:year', today.getFullYear())
}
</script>
