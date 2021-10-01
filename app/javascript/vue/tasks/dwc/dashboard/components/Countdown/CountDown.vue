<template>
  <span>{{ displayCountdown }}</span>
</template>
<script setup>

import { computed, ref, watch } from 'vue'
import CountDown from './countdown.js'

const props = defineProps({
  startDate: {
    type: [Date, Number],
    default: () => new Date()
  },
  endDate: {
    type: [Date, Number],
    required: true
  }
})

const emit = defineEmits(['onComplete'])

const seconds = ref(0)
const minutes = ref(0)
const hours = ref(0)
const displayCountdown = computed(() => `${twoDigits(hours.value)}:${twoDigits(minutes.value)}:${twoDigits(seconds.value)}`)

const updateTime = (time) => {
  hours.value = time.hours
  minutes.value = time.minutes
  seconds.value = time.seconds
}

const twoDigits = (number) => (number).toLocaleString(undefined, { minimumIntegerDigits: 2 })

const onComplete = () => {
  emit('onComplete', true)
}
const countdown = new CountDown(0, 0, updateTime, onComplete)

watch([() => props.startDate, () => props.endDate], () => {
  if (props.startDate && props.endDate) {
    countdown.setExpiredDate(props.startDate, props.endDate)
  }
}, { immediate: true })

</script>
