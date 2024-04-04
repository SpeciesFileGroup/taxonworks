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
        ref="taxonDeterminationFormRef"
        class="margin-medium-bottom"
        @on-add="
          (determination) =>
            addToArray(taxonDeterminations, determination, { property: 'uuid' })
        "
      />
      <TaxonDeterminationList
        v-model="taxonDeterminations"
        @edit="editTaxonDetermination"
      />
    </div>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!taxonDeterminations.length || isCountExceeded"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectionObject.batchUpdate"
        :payload="payload"
        :disabled="!taxonDeterminations.length || isCountExceeded"
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
import { addToArray } from '@/helpers'
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from '@/components/TaxonDetermination/TaxonDeterminationList.vue'

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

const taxonDeterminations = ref([])
const taxonDeterminationFormRef = ref(null)
const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const payload = computed(() => ({
  collection_object_query: props.parameters,
  collection_object: {
    taxon_determinations_attributes: taxonDeterminations.value.map(
      (determination) => ({
        day_made: determination.day_made,
        month_made: determination.month_made,
        year_made: determination.year_made,
        otu_id: determination.otu_id,
        roles_attributes: determination.roles_attributes
      })
    )
  }
}))

function editTaxonDetermination(item) {
  taxonDeterminationFormRef.value.setDetermination({ ...item })
}

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
