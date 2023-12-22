<template>
  <div>
    <VSpinner
      v-if="isUpdating"
      legend="Updating..."
    />
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div v-else>
      <h3>{{ count }} records will be updated</h3>

      <fieldset>
        <legend>Collector</legend>
        <smart-selector
          ref="smartSelector"
          model="people"
          target="Collector"
          klass="CollectingEvent"
          :params="{ role_type: 'Collector' }"
          :autocomplete-params="{
        roles: ['Collector']
      }"
          label="cached"
          :autocomplete="false"
          @selected="addRole"
        >
          <template #header>
            <role-picker
              hidden-list
              v-model="collectingEvent.roles_attributes"
              ref="rolepicker"
              :autofocus="false"
              role-type="Collector"
            />
          </template>
          <role-picker
            :create-form="false"
            v-model="collectingEvent.roles_attributes"
            :autofocus="false"
            role-type="Collector"
          />
        </smart-selector>
      </fieldset>

      <div
        class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
      >
        <UpdateBatch
          ref="updateBatchRef"
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="!collectingEvent.roles_attributes || isCountExceeded"
          @update="updateMessage"
          @close="emit('close')"
        />

        <PreviewBatch
          :batch-service="CollectingEvent.batchUpdate"
          :payload="payload"
          :disabled="!collectingEvent.roles_attributes || isCountExceeded"
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
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
import VSpinner from '@/components/spinner.vue'
import { CollectingEvent } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import RolePicker from '@/components/role_picker.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'

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
const isUpdating = ref(false)
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const updateBatchRef = ref(null)

const rolepicker = ref(null)
const addRole = (role) => {
  rolepicker.value.addCreatedPerson({
    object_id: role.id,
    label: role.cached
  })
}

const collectingEvent = ref({ roles_attributes: [] })

const payload = computed(() => ({
  collecting_event_query: props.parameters,
  collecting_event: {
    roles_attributes:
      // remove position so roles are appended to end of list
      collectingEvent.value.roles_attributes.map(({position, ...rest}) => rest)
  }
}))

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collection objects queued for updating.`
    : `${data.updated.length} collection objects were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>
