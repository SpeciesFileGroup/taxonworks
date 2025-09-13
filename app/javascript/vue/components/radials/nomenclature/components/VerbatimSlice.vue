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
            :is="component.tag"
            rows="5"
            class="full_width"
            v-bind="component.bind"
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
        :batch-service="TaxonName.batchUpdate"
        :payload="payload"
        :disabled="!updateFields.length || isCountExceeded"
        @update="updateMessage"
        @close="emit('close')"
      />

      <PreviewBatch
        :batch-service="TaxonName.batchUpdate"
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
import { TaxonName } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import { addToArray, humanize } from '@/helpers'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'

const MAX_LIMIT = 250

const VERBATIM_FIELDS = {
  verbatim_author: {
    tag: 'input',
    bind: {
      type: 'text'
    }
  },
  verbatim_year: {
    tag: 'input',
    bind: {
      type: 'number'
    }
  }
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

const updateBatchRef = ref(null)
const updateFields = ref([])
const fields = ref({})

const payload = computed(() => ({
  taxon_name_query: props.parameters,
  taxon_name: {
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
    ? `${data.updated.length} taxon names queued for updating.`
    : `${data.updated.length} taxon names were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}

function makeLabel(property) {
  return humanize(property.slice(8))
}
</script>
