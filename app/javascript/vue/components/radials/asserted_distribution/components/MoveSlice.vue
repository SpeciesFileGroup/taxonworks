<template>
  <div>
    <VSpinner v-if="isLoading" />
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
      <VBtn
        color="create"
        medium
        :disabled="!geographicArea"
        @click="update"
      >
        Update
      </VBtn>

      <PreviewBatch
        :batch-service="AssertedDistribution.batchUpdate"
        :payload="payload"
        :disabled="!geographicArea"
      />
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/spinner.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import { AssertedDistribution } from '@/routes/endpoints'
import { ASSERTED_DISTRIBUTION } from '@/constants/index.js'
import { ref, computed } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const isLoading = ref(false)
const geographicArea = ref()
const response = ref({
  updated: [],
  not_updated: []
})

const payload = computed(() => {
  return {
    asserted_distribution_query: props.parameters,
    asserted_distribution: {
      geographic_area_id: geographicArea.value?.id
    }
  }
})

async function update() {
  isLoading.value = true
  await makeRequest(payload.value)
  isLoading.value = false

  TW.workbench.alert.create(
    `${response.value.updated.length} asserted distribution items were successfully updated.`,
    'notice'
  )
}

async function makeRequest(payload) {
  return AssertedDistribution.batchUpdate(payload)
    .then(({ body }) => {
      response.value = body
    })
    .catch(() => {})
}
</script>
