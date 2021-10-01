<template>
  <spinner-component
    v-if="isReindexFinished"
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
import CountDown from 'tasks/dwc/dashboard/components/Countdown/CountDown.vue'

const CALL_DELAY = 2000
const samplesToUpdate = ref([])
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
const isReindexFinished = computed(() => !!samplesToUpdate.value.length)

const percentComplete = computed(() => {
  const totalSamples = props.reindex.sample.length
  const totalRecords = props.reindex.total
  const totalPerSample = totalRecords / (totalSamples - 1)

  const updatedSamples = totalSamples - samplesToUpdate.value.length
  const sampleRecords = totalPerSample * (updatedSamples - 1)

  switch (updatedSamples) {
    case 0:
      return 0
    case 1:
      return ((1 * 100) / totalRecords).toFixed(2)
    default:
      return ((sampleRecords * 100) / totalRecords).toFixed(2)
  }
})

const checkSamplesUpdate = () => {
  if (samplesToUpdate.value.length) {
    const sampleGlobalId = samplesToUpdate.value[0]

    DwcOcurrence.status({ object_global_id: sampleGlobalId }).then(({ body }) => {
      const updateTime = new Date(body.updated_at).getTime()

      if (sampleDate < updateTime) {
        samplesToUpdate.value.splice(0, 1)
        updateCountdown(updateTime)
      }

      if (samplesToUpdate.value.length) {
        timeoutId = setTimeout(() => { checkSamplesUpdate() }, CALL_DELAY)
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

  return sampleDate + (timeDiff * samplesToUpdate.value.length)
}

watch(() => props.reindex, reindex => {
  previousDate = 0
  sampleDate = new Date(reindex.start_time).getTime()
  samplesToUpdate.value = reindex.sample.slice()

  checkSamplesUpdate()
})

</script>
