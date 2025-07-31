<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <h3>{{ count }} records will be updated</h3>

      <fieldset>
        <legend>Taxon name</legend>
        <SmartSelector
          model="taxon_names"
          :klass="TAXON_NAME"
          :target="TAXON_NAME"
          @selected="(item) => (taxonName = item)"
        />
        <SmartSelectorItem
          :item="taxonName"
          label="name"
          @unset="() => (taxonName = undefined)"
        />
      </fieldset>

      <div
        class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
      >
        <UpdateBatch
          ref="updateBatchRef"
          :batch-service="Otu.batchUpdate"
          :payload="payload"
          :disabled="!taxonName || isCountExceeded"
          @update="updateMessage"
          @close="emit('close')"
        />

        <PreviewBatch
          :batch-service="Otu.batchUpdate"
          :payload="payload"
          :disabled="!taxonName || isCountExceeded"
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
import { Otu } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants/index.js'
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

const taxonName = ref()
const updateBatchRef = ref(null)
const emit = defineEmits(['close'])

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => ({
  otu_query: props.parameters,
  otu: {
    taxon_name_id: taxonName.value?.id
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} OTUs queued for updating.`
    : `${data.updated.length} asserted distribution items were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
