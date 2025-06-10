<template>
  <div>
    <h3>New asserted distribution</h3>

    <FormCitation
      v-model="citation"
      v-model:absent="isAbsent"
      :klass="ASSERTED_DISTRIBUTION"
      :target="ASSERTED_DISTRIBUTION"
      absent-field
      use-session
    />

    <fieldset class="margin-medium-top">
      <legend>Shape</legend>
      <ShapeSelector @select-shape="(s) => (shape = s)" />
      <SmartSelectorItem
        :item="shape"
        label="name"
        @unset="() => (shape = undefined)"
      />
    </fieldset>
    <div class="horizontal-left-content gap-small margin-medium-top">
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="AssertedDistribution.batchTemplateCreate"
        :payload="payload"
        :disabled="!citation.source_id || !shape || isCountExceeded"
        confirmation-word="CREATE"
        button-label="Create"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="AssertedDistribution.batchTemplateCreate"
        :payload="payload"
        :disabled="!citation.source_id || !shape || isCountExceeded"
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
import { ref, computed } from 'vue'
import { ASSERTED_DISTRIBUTION } from '@/constants/index'
import { AssertedDistribution } from '@/routes/endpoints'
import ShapeSelector from '@/components/ui/SmartSelector/ShapeSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

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

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const shape = ref()
const isAbsent = ref()
const citation = ref({
  source_id: undefined,
  pages: undefined,
  is_original: undefined
})

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => ({
  otu_query: props.parameters,
  asserted_distribution: {
    asserted_distribution_shape_type: shape.value?.shapeType,
    asserted_distribution_shape_id: shape.value?.id,
    citations_attributes: [citation.value],
    is_absent: isAbsent.value
  }
}))

function updateMessage(data) {
  const message = data.async
    ? `${data.total_attempted} asserted distributions queued for creation.`
    : `${data.updated.length} asserted distribution items were successfully created.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
