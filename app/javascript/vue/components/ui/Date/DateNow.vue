<template>
  <v-btn
    color="primary"
    medium
    @click="setTime"
  >
    Now
  </v-btn>
</template>

<script setup>
import { convertToTwoDigits } from 'helpers/numbers'
import VBtn from 'components/ui/VBtn/index.vue'

const emit = defineEmits([
  'update:day',
  'update:month',
  'update:year',
  'update:time'
])

const setTime = () => {
  const today = new Date()
  const time = [
    convertToTwoDigits(today.getHours()),
    convertToTwoDigits(today.getMinutes()),
    convertToTwoDigits(today.getSeconds())
  ].join(':')

  emit('update:time', time)
  emit('update:day', today.getDate())
  emit('update:month', today.getMonth() + 1)
  emit('update:year', today.getFullYear())
}

</script>
