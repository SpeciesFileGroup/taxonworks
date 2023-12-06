<template>
  <div>
    <fieldset>
      <legend>Geographic area</legend>
      <SmartSelector
        model="geographic_areas"
        :klass="ASSERTED_DISTRIBUTION"
        :target="ASSERTED_DISTRIBUTION"
        label="name"
        @selected="(item) => (geographicArea = item)"
      />
      <SmartSelectorItem
        :item="geographicArea"
        label="name"
        @unset="geographicArea = undefined"
      />
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="AssertedDistribution.batchUpdate"
        :payload="payload"
        :disabled="!geographicArea"
        @update="updateMessage"
      />

      <PreviewBatch
        :batch-service="AssertedDistribution.batchUpdate"
        :payload="payload"
        :disabled="!geographicArea"
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
import { AssertedDistribution } from '@/routes/endpoints'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'
import { ref, computed } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const updateBatchRef = ref(null)
const geographicArea = ref()

const payload = computed(() => {
  return {
    asserted_distribution_query: props.parameters,
    asserted_distribution: {
      geographic_area_id: geographicArea.value?.id
    }
  }
})

function updateMessage(data) {
  TW.workbench.alert.create(
    `${data.updated.length} asserted distribution items were successfully updated.`,
    'notice'
  )
}
</script>
