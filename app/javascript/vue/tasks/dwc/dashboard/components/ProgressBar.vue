<template>
  <spinner-component
    v-if="isReindexFinished"
    :legend="message"
    :show-legend="false"
  >
    Reindexing... {{ percentComplete }}% completed. Estimated time:
    <CountDown
      :start-date="sampleDate"
      :end-date="lastTime"
    />
  </spinner-component>
</template>
<script setup>

import { computed, ref, watch } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import SpinnerComponent from 'components/spinner.vue'
import CountDown from './Countdown/CountDown.vue'

const CALL_DELAY = 1000
const samplesUpdated = ref([])
const props = defineProps({
  reindex: {
    type: Object,
    required: true
  }
})
const emit = defineEmits(['onReady'])
let sampleDate
let timeoutId
let previousDate = 0

const lastTime = ref(0)
const isReindexFinished = computed(() => !!samplesUpdated.value.length)
const percentComplete = computed(() => Math.trunc(100 - ((samplesUpdated.value.length * 100) / props.reindex.sample?.length)))

const checkSamplesUpdate = () => {
  if (samplesUpdated.value.length) {
    const sampleGlobalId = samplesUpdated.value[0]

    DwcOcurrence.status({ object_global_id: sampleGlobalId }).then(({ body }) => {
      const updateTime = new Date(body.updated_at).getTime()

      if (sampleDate < updateTime) {
        samplesUpdated.value.splice(0, 1)
        updateCountdown(updateTime)
      }

      if (samplesUpdated.value.length) {
        timeoutId = setTimeout(() => { checkSamplesUpdate() }, CALL_DELAY)
      } else {
        emit('onReady', true)
      }
    })
  }
}

const updateCountdown = (updateTime) => {
  lastTime.value = calculateEstimatedTime(updateTime)
  previousDate = updateTime
}

const calculateEstimatedTime = (updatedDate) => {
  const timeDiff = updatedDate - (previousDate || sampleDate) + CALL_DELAY

  return sampleDate + (timeDiff * samplesUpdated.value.length)
}

watch(() => props.reindex, reindex => {
  previousDate = 0
  sampleDate = new Date(reindex.start_time).getTime()
  samplesUpdated.value = reindex.sample.slice()

  checkSamplesUpdate()
})

</script>
