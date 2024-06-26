<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <label>Container</label>
    <VAutocomplete
      url="/containers/autocomplete"
      label="label_html"
      clear-after
      placeholder="Search a container..."
      param="term"
      @get-item="(item) => (container = item)"
    />
    <SmartSelectorItem
      :item="container"
      label="label_html"
      @unset="container = null"
    />

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="ContainerItem.batchAdd"
        :payload="payload"
        :disabled="!container"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="ContainerItem.batchAdd"
        :payload="payload"
        :disabled="!container"
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
import { ContainerItem } from '@/routes/endpoints'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'

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

const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const container = ref(null)

const payload = computed(() => ({
  collection_object_query: props.parameters,
  container_id: container.value?.id
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
