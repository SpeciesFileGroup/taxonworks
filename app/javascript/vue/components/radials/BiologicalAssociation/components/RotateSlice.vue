<template>
  <div
    v-if="isCountExceeded"
    class="feedback feedback-danger"
  >
    Too many records selected, maximum {{ MAX_LIMIT }}
  </div>
  <div
    class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
  >
    <UpdateBatch
      ref="updateBatchRef"
      :batch-service="BiologicalAssociation.batchUpdate"
      :payload="payload"
      :disabled="isCountExceeded"
      @update="updateMessage"
      @close="emit('close')"
    />

    <PreviewBatch
      :batch-service="BiologicalAssociation.batchUpdate"
      :payload="payload"
      :disabled="isCountExceeded"
      @finalize="
        () => {
          updateBatchRef.openModal()
        }
      "
    />
  </div>
</template>

<script setup>
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import { BiologicalAssociation } from '@/routes/endpoints'
import { computed, ref } from 'vue'

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

const updateBatchRef = ref(null)
const emit = defineEmits(['close'])

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => ({
  biological_association_query: props.parameters,
  biological_association: {
    rotate: true
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} biological association queued for updating.`
    : `${data.updated.length} biological associations were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
