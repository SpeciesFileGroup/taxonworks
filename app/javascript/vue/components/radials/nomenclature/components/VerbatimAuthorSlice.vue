<template>
  <div>
    <div class="field label-above">
      <label>Verbatim author</label>
      <input
        type="text"
        v-model="verbatimAuthor"
      />
    </div>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="TaxonName.batchUpdate"
        :payload="payload"
        :disabled="!verbatimAuthor"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="TaxonName.batchUpdate"
        :payload="payload"
        :disabled="!verbatimAuthor"
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
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import { TaxonName } from '@/routes/endpoints'
import { ref, computed } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const verbatimAuthor = ref()
const payload = computed(() => ({
  taxon_name_query: props.parameters,
  taxon_name: {
    verbatim_author: verbatimAuthor.value
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} taxon names queued for updating.`
    : `${data.updated.length} taxon names were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
