<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <h3>
        {{ count }} {{ count === 1 ? 'record' : 'records' }} will be updated
      </h3>
      <i>* Only fields that are checked will be updated.</i>
      <div
        v-for="(component, property) in VERBATIM_FIELDS"
        :key="property"
        class="field margin-medium-top"
      >
        <label class="horizontal-left-content middle">
          <input
            type="checkbox"
            :value="property"
            v-model="updateFields"
          />
          {{ makeLabel(property) }}
        </label>
        <div class="flex-row full_width align-start">
          <component
            :is="component"
            rows="5"
            class="full_width"
            @input="
              (e) => {
                fields[property] = e.target.value
                addToArray(updateFields, property, { primitive: true })
              }
            "
          />
        </div>
      </div>
    </div>
    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <UpdateBatch
        ref="updateBatchRef"
        :batch-service="CollectingEvent.batchUpdate"
        :payload="payload"
        :disabled="!updateFields.length || isCountExceeded"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="CollectingEvent.batchUpdate"
        :payload="payload"
        :disabled="!updateFields.length || isCountExceeded"
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
import { CollectingEvent } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import { addToArray, humanize } from '@/helpers'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

const MAX_LIMIT = 250

const VERBATIM_FIELDS = {
  verbatim_label: 'textarea',
  verbatim_locality: 'textarea',
  verbatim_latitude: 'input',
  verbatim_longitude: 'input',
  verbatim_geolocation_uncertainty: 'input',
  verbatim_elevation: 'input',
  verbatim_habitat: 'input',
  verbatim_date: 'input',
  verbatim_datum: 'input',
  verbatim_collectors: 'textarea',
  verbatim_method: 'input',
  verbatim_field_number: 'input'
}

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

const updateFields = ref([])
const fields = ref({})
const updateBatchRef = ref(null)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)

const payload = computed(() => ({
  collecting_event_query: props.parameters,
  collecting_event: {
    ...Object.fromEntries(
      updateFields.value.map((property) => [
        property,
        fields.value[property] || null
      ])
    )
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collecting events queued for updating.`
    : `${data.updated.length} collection events were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}

function makeLabel(property) {
  return humanize(property.slice(8))
}
</script>
