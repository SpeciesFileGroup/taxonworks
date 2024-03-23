<template>
  <div>
    <fieldset>
      <legend>Taxon name</legend>
      <SmartSelector
        model="taxon_names"
        :klass="TAXON_NAME"
        :target="TAXON_NAME"
        @selected="(item) => (parent = item)"
      />
      <SmartSelectorItem
        :item="parent"
        label="name"
        @unset="parent = undefined"
      />
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="TaxonName.batchUpdate"
        :payload="payload"
        :disabled="!parent"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="TaxonName.batchUpdate"
        :payload="payload"
        :disabled="!parent"
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
import { TaxonName } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants/index.js'
import { ref, computed } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const parent = ref()
const payload = computed(() => ({
  taxon_name_query: props.parameters,
  taxon_name: {
    parent_id: parent.value?.id
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} taxon names queued for updating.`
    : `${data.updated.length} taxon names were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
