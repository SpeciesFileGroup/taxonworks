<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div>
      <TaxonDeterminationForm
        @on-add="(determination) => (taxonDetermination = determination)"
      />
    </div>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!taxonDetermination || isCountExceeded"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!taxonDetermination || isCountExceeded"
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
import { computed, ref } from 'vue'
import { CollectionObject } from '@/routes/endpoints'
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'

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

const taxonDetermination = ref(null)
const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const payload = computed(() => ({
  collection_object_query: props.parameters,
  collection_object: {
    taxon_determinations_attributes: [
      {
        day_made: taxonDetermination.value?.day_made,
        month_made: taxonDetermination.value?.month_made,
        year_made: taxonDetermination.value?.year_made,
        otu_id: taxonDetermination.value?.otu_id,
        roles_attributes: taxonDetermination.value?.roles_attributes
      }
    ]
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
