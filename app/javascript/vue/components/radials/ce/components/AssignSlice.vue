<template>
  <div>
    <VSpinner
      v-if="isUpdating"
      legend="Updating..."
    />
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <h3>{{ count }} records will be updated</h3>

      <fieldset>
        <legend>Geographic area</legend>
        <SmartSelector
          model="geographic_areas"
          label="name"
          :target="COLLECTING_EVENT"
          :klass="COLLECTING_EVENT"
          @selected="(item) => (geographicArea = item)"
        />
        <SmartSelectorItem
          label="name"
          :item="geographicArea"
          @unset="geographicArea = undefined"
        />
      </fieldset>

      <div
        class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
      >
        <UpdateBatch
          ref="updateBatchRef"
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="!geographicArea || isCountExceeded"
          @update="updateMessage"
          @close="emit('close')"
        />

        <PreviewBatch
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="!geographicArea || isCountExceeded"
          @finalize="
            () => {
              updateBatchRef.openModal()
            }
          "
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import VSpinner from '@/components/spinner.vue'
import { COLLECTING_EVENT } from '@/constants/index.js'
import { CollectingEvent } from '@/routes/endpoints'
import { ref, computed } from 'vue'

const MAX_LIMIT = 250

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const geographicArea = ref()
const isUpdating = ref(false)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const updateBatchRef = ref(null)

const payload = computed(() => ({
  collecting_event_query: props.parameters,
  collecting_event: {
    geographic_area_id: geographicArea.value?.id
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
