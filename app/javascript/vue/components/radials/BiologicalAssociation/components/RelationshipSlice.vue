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
        <legend>Biological relationship</legend>
        <SmartSelector
          model="biological_relationships"
          :klass="BIOLOGICAL_ASSOCIATION"
          :target="BIOLOGICAL_ASSOCIATION"
          @selected="(item) => (biologicalAssociation = item)"
        />
        <SmartSelectorItem
          :item="biologicalAssociation"
          label="name"
          @unset="biologicalAssociation = undefined"
        />
      </fieldset>

      <div
        class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
      >
        <UpdateBatch
          ref="updateBatchRef"
          :batch-service="BiologicalAssociation.batchUpdate"
          :payload="payload"
          :disabled="!biologicalAssociation || isCountExceeded"
          @update="updateMessage"
          @close="emit('close')"
        />

        <PreviewBatch
          :batch-service="BiologicalAssociation.batchUpdate"
          :payload="payload"
          :disabled="!biologicalAssociation || isCountExceeded"
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
import { BiologicalAssociation } from '@/routes/endpoints'
import { BIOLOGICAL_ASSOCIATION } from '@/constants/index.js'
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

const biologicalAssociation = ref()
const updateBatchRef = ref(null)
const emit = defineEmits(['close'])

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => ({
  biological_association_query: props.parameters,
  biological_association: {
    biological_relationship_id: biologicalAssociation.value?.id
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} biological association queued for updating.`
    : `${data.updated.length} biological associations were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
