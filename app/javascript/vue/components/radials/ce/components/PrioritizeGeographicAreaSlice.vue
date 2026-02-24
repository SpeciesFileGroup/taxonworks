<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <h3>
        {{ count }} {{ count === 1 ? 'record' : 'records' }} will be updated
      </h3>

      <fieldset>
        <legend>Indexing</legend>
        <label>
          <input
            type="radio"
            name="prioritize-geographic-area"
            :value="true"
            v-model="prioritizeGeographicArea"
          />
          Prioritize geographic area
        </label>
        <label>
          <input
            type="radio"
            name="prioritize-geographic-area"
            :value="false"
            v-model="prioritizeGeographicArea"
          />
          Do not prioritize geographic area
        </label>
      </fieldset>

      <div
        class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
      >
        <UpdateBatch
          ref="updateBatchRef"
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="prioritizeGeographicArea === null || isCountExceeded"
          @update="updateMessage"
          @close="emit('close')"
        />

        <PreviewBatch
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="prioritizeGeographicArea === null || isCountExceeded"
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
import { CollectingEvent } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import updateMessage from '../utils/updateMessage.js'

const MAX_LIMIT = 1000

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

const emit = defineEmits(['close'])
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const updateBatchRef = ref(null)
const prioritizeGeographicArea = ref(null)

const payload = computed(() => ({
  collecting_event_query: props.parameters,
  collecting_event: {
    meta_prioritize_geographic_area: prioritizeGeographicArea.value
  }
}))
</script>
