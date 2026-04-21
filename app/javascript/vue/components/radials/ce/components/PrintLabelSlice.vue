<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <div class="field">
        <div class="margin-xsmall-bottom">Label attribute</div>
        <ul class="no_bullets">
          <li
            v-for="attr in LABEL_ATTRIBUTES"
            :key="attr"
          >
            <label>
              <input
                type="radio"
                :value="attr"
                v-model="selectedLabelAttribute"
              />
              {{ humanize(attr) }}
            </label>
          </li>
        </ul>
      </div>
      <div class="field label-above">
        <label>Number to print</label>
        <input
          class="w-16"
          type="number"
          v-model="total"
        />
      </div>
    </div>
    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        button-label="Create"
        confirmation-word="CREATE"
        :batch-service="Label.batchCreate"
        :payload="payload"
        :disabled="isCreateAvailable"
        @update="(data) => toastCreation(data)"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="Label.batchCreate"
        :payload="payload"
        :disabled="isCreateAvailable"
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
import { Label } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import { humanize } from '@/helpers'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

const MAX_LIMIT = 1000

const LABEL_ATTRIBUTES = ['verbatim_label', 'document_label', 'print_label']

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

const total = ref(1)
const updateBatchRef = ref(null)
const selectedLabelAttribute = ref()
const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const isCreateAvailable = computed(
  () =>
    !selectedLabelAttribute.value || total.value < 1 || isCountExceeded.value
)

const payload = computed(() => ({
  collecting_event_query: props.parameters,
  label_attribute: selectedLabelAttribute.value,
  total: total.value
}))

function toastCreation(data) {
  const message = data.async
    ? `${data.total_attempted} labels queued for creation.`
    : `${data.updated.length} labels were successfully created.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
