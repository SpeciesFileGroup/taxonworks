<template>
  <div class="replace-sources-root">
    <VSpinner
      v-if="isLoading"
      legend="Loading..."
    />

    <div class="replace-sources-header">
      <span>Sources from filter (check to replace)</span>
      <VBtn
        color="primary"
        type="button"
        :disabled="!sourcesFromQuery.length"
        @click="selectAllSources"
      >
        Select all
      </VBtn>
    </div>
    <fieldset class="replace-sources-fieldset replace-sources-list-fieldset">
      <legend>Sources</legend>
      <div
        v-if="sourcesFromQuery.length"
        class="replace-sources-scroll"
      >
        <ul class="no_bullets replace-sources-list">
          <li
            v-for="sourceItem in sourcesFromQuery"
            :key="sourceItem.id"
          >
            <label>
              <input
                type="checkbox"
                v-model="removeSourceIds"
                :value="sourceItem.id"
              />
              <span v-html="sourceItem.cached" />
            </label>
          </li>
        </ul>
      </div>
      <div v-else>
        <em>No sources found in filter results.</em>
      </div>
    </fieldset>

    <fieldset class="replace-sources-fieldset">
      <legend>Replacement source</legend>
      <SmartSelector
        model="sources"
        :klass="ASSERTED_DISTRIBUTION"
        :target="ASSERTED_DISTRIBUTION"
        label="cached"
        pin-section="Sources"
        pin-type="Source"
        @selected="(selectedSource) => (source = selectedSource)"
      />
      <SmartSelectorItem
        :item="source"
        label="cached"
        @unset="() => (source = null)"
      />
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom replace-sources-actions"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="AssertedDistribution.batchUpdate"
        :payload="payload"
        :disabled="isDisabled"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="AssertedDistribution.batchUpdate"
        :payload="payload"
        :disabled="isDisabled"
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
import { computed, ref, watch } from 'vue'
import { ASSERTED_DISTRIBUTION } from '@/constants'
import { AssertedDistribution } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const updateBatchRef = ref(null)
const source = ref(null)
const removeSourceIds = ref([])
const sourcesFromQuery = ref([])
const isLoading = ref(false)

const normalizedRemoveSourceIds = computed(() => {
  const targetId = source.value?.id
  return removeSourceIds.value.filter((id) => id !== targetId)
})

const payload = computed(() => ({
  asserted_distribution_query: props.parameters,
  asserted_distribution: {
    source_id: source.value?.id,
    remove_source_ids: normalizedRemoveSourceIds.value
  }
}))

const isDisabled = computed(() => {
  return !source.value || normalizedRemoveSourceIds.value.length == 0
})

watch(source, (newVal) => {
  if (!newVal) return
  removeSourceIds.value = removeSourceIds.value.filter((id) => id !== newVal.id)
})

watch(
  () => props.parameters,
  () => {
    isLoading.value = true
    AssertedDistribution.sources({
      filter_query: { asserted_distribution_query: props.parameters }
    })
      .then(({ body }) => {
        sourcesFromQuery.value = body
      })
      .catch(() => {
        sourcesFromQuery.value = []
      })
      .finally(() => {
        isLoading.value = false
      })
  },
  { immediate: true, deep: true }
)

function updateMessage(data) {
  const message = data.async
    ? 'Asserted distributions will be updated in the background.'
    : `${data.updated.length} asserted distributions were successfully updated.`

  TW.workbench.alert.create(
    message,
    'notice'
  )
}

function selectAllSources() {
  const targetId = source.value?.id
  removeSourceIds.value = sourcesFromQuery.value
    .map((sourceItem) => sourceItem.id)
    .filter((id) => id !== targetId)
}
</script>

<style scoped>
.replace-sources-root {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.replace-sources-fieldset {
  margin-bottom: 0;
}

.replace-sources-list-fieldset {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.replace-sources-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.replace-sources-scroll {
  max-height: 100%;
  overflow-y: auto;
  padding-right: 6px;
}

.replace-sources-list li:nth-child(even) {
  background: #f5f5f5;
}

.replace-sources-list li {
  padding: 4px 6px;
  border-radius: 4px;
}

.replace-sources-list li label {
  display: block;
}

.replace-sources-actions {
  gap: 12px;
}
</style>
