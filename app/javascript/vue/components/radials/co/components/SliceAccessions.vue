<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <div class="field label-above">
      <label>Accesssioned at</label>
      <input
        type="date"
        v-model="data.accessioned_at"
      />
    </div>
    <div class="field label-above">
      <label>Deaccesssioned at</label>
      <input
        type="date"
        v-model="data.deaccessioned_at"
      />
    </div>
    <div class="field label-above">
      <label>Deaccession reason</label>
      <input
        type="text"
        v-model="data.deaccession_reason"
      />
    </div>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="isDisabled"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="isDisabled"
        @finalize="
          () => {
            updateBatchRef.openModal()
          }
        "
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { CollectionObject } from '@/routes/endpoints'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

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

const data = ref({
  accessioned_at: undefined,
  deaccessioned_at: undefined,
  deaccession_reason: undefined
})

const isDisabled = computed(() => !Object.values(data.value).some(Boolean))

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => ({
  collection_object_query: props.parameters,
  collection_object: {
    ...data.value
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
