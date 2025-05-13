<template>
  <div>
    <ShapeSelector
      @selectShape="(selectedShape) => (shape = selectedShape)"
    />
    <SmartSelectorItem
      :item="shape"
      label="name"
      @unset="() => (shape = undefined)"
    />

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="AssertedDistribution.batchUpdate"
        :payload="payload"
        :disabled="!shape"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="AssertedDistribution.batchUpdate"
        :payload="payload"
        :disabled="!shape"
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
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import ShapeSelector from '@/components/ui/SmartSelector/ShapeSelector.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import { AssertedDistribution } from '@/routes/endpoints'
import { ref, computed } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const shape = ref()

const payload = computed(() => {
  return {
    asserted_distribution_query: props.parameters,
    asserted_distribution: {
      asserted_distribution_shape_type: shape.value?.shapeType,
      asserted_distribution_shape_id: shape.value?.id
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
