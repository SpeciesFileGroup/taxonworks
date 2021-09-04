<template>
  <spinner-component
    v-if="false"
    full-screen
  />
</template>
<script setup>

import { computed, ref, watch } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import SpinnerComponent from 'components/spinner.vue'

const CALL_DELAY = 5000
const samplesUpdated = ref([])
const props = defineProps({
  reindex: {
    type: Object,
    required: true
  }
})
let checkSample
let sampleDate
let timeout

const finished = computed(() => !samplesUpdated.value.length)
const checkSamplesUpdate = () => {
  const coRequests = samplesUpdated.value.map(global_id => 
    CollectionObject.where({
      object_global_id: encodeURIComponent(global_id)
    })
  )

  Promise.all(coRequests).then(responses => {
    const collectionObjects = responses.map(({ body }) => body)

    samplesUpdated.value = collectionObjects.filter(co => {
      const updateDate = new Date(co.updated_at).getTime()

      return sampleDate > updateDate
    })

    if (samplesUpdated.value.length) {
      timeout = setTimeout(checkSamplesUpdate(), CALL_DELAY)
    }
  })
}

watch(() => props.reindex, reindex => {
  samplesUpdated.value = reindex.samples
  sampleDate = new Date(reindex.start_time)

  checkSamplesUpdate()
})

</script>
