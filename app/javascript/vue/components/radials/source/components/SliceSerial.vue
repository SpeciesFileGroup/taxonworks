<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <fieldset>
      <legend>Serial</legend>
      <SmartSelector
        model="serials"
        :klass="SOURCE"
        :target="SOURCE"
        label="name"
        @selected="(item) => (serial = item)"
      />
      <SmartSelectorItem
        :item="serial"
        label="name"
        @unset="serial = undefined"
      />
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="Source.batchUpdate"
        :payload="payload"
        :disabled="!serial || isCountExceeded"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="Source.batchUpdate"
        :payload="payload"
        :disabled="!serial || isCountExceeded"
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
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import { Source } from '@/routes/endpoints'
import { SOURCE } from '@/constants/index.js'
import { computed, ref } from 'vue'

const MAX_LIMIT = 50

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

const serial = ref()
const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => {
  return {
    source_query: props.parameters,
    source: {
      serial_id: serial.value?.id
    }
  }
})

function updateMessage(data) {
  TW.workbench.alert.create(
    `${data.updated.length} sources were successfully updated.`,
    'notice'
  )
}
</script>
