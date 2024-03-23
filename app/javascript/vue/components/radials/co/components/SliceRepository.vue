<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <fieldset>
      <legend>Repository</legend>
      <SmartSelector
        model="repositories"
        :target="COLLECTION_OBJECT"
        :klass="COLLECTION_OBJECT"
        @selected="(item) => (repository = item)"
      />
      <SmartSelectorItem
        :item="repository"
        @unset="repository = undefined"
      />
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!repository"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!repository"
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
import { COLLECTION_OBJECT } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

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
const repository = ref(null)

const payload = computed(() => ({
  collection_object_query: props.parameters,
  collection_object: {
    repository_id: repository.value?.id
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
