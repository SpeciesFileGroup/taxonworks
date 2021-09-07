<template>
  <spinner-component
    v-if="reindexFinished"
    :legend="message"
  />
</template>
<script setup>

import { computed, ref, watch } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import SpinnerComponent from 'components/spinner.vue'

const CALL_DELAY = 5000
const samplesUpdated = ref([])
const props = defineProps({
  reindex: {
    type: Object,
    required: true
  }
})
let sampleDate
let timeout

const reindexFinished = computed(() => samplesUpdated.value.length)

const message = computed(() => `Reindexing... ${100 - ((samplesUpdated.value.length * 100) / props.reindex.sample?.length)}% completed`)

const getTime = date => new Date(date).getTime()

const checkSamplesUpdate = () => {
  const coRequests = samplesUpdated.value.map(globalId =>
    DwcOcurrence.status({ object_global_id: globalId })
  )

  Promise.all(coRequests).then(responses => {
    const dwcOcurrenceRows = responses.map(({ body }) => body)

    samplesUpdated.value = dwcOcurrenceRows
      .filter(row => sampleDate > getTime(row.updated_at))
      .map(item => item.object)

    if (samplesUpdated.value.length) {
      timeout = setTimeout(() => { checkSamplesUpdate() }, CALL_DELAY)
    }
  })
}

watch(() => props.reindex, reindex => {
  samplesUpdated.value = reindex.sample
  sampleDate = getTime(reindex.start_time)

  checkSamplesUpdate()
})

</script>
