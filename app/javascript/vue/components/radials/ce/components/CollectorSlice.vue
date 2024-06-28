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

      <fieldset>
        <legend>Collector</legend>
        <smart-selector
          ref="smartSelector"
          model="people"
          :target="ROLE_COLLECTOR"
          :klass="COLLECTING_EVENT"
          :params="{ role_type: ROLE_COLLECTOR }"
          :autocomplete-params="{
            roles: [ROLE_COLLECTOR]
          }"
          label="cached"
          :autocomplete="false"
          @selected="addRole"
        >
          <template #header>
            <role-picker
              v-model="collectingEvent.roles_attributes"
              ref="rolepicker"
              hidden-list
              :autofocus="false"
              :role-type="ROLE_COLLECTOR"
            />
          </template>
          <role-picker
            v-model="collectingEvent.roles_attributes"
            :create-form="false"
            :autofocus="false"
            :role-type="ROLE_COLLECTOR"
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
import { CollectingEvent } from '@/routes/endpoints'
import { ref, computed } from 'vue'
import { COLLECTING_EVENT, ROLE_COLLECTOR } from '@/constants'
import PreviewBatch from '@/components/radials/shared/PreviewBatch.vue'
import UpdateBatch from '@/components/radials/shared/UpdateBatch.vue'
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
const isCountExceeded = computed(() => props.count > MAX_LIMIT)
const updateBatchRef = ref(null)
const rolepicker = ref(null)
const collectingEvent = ref({ roles_attributes: [] })

const payload = computed(() => ({
  collecting_event_query: props.parameters,
  collecting_event: {
    roles_attributes:
      // remove position so roles are appended to end of list
      collectingEvent.value.roles_attributes.map(
        ({ position, ...rest }) => rest
      )
  }
}))

function addRole(role) {
  rolepicker.value.addPerson(role)
}

function updateMessage(data) {
  const message = data.sync
    ? `${data.updated.length} collecting events queued for updating.`
    : `${data.updated.length} collecting events were successfully updated.`

  TW.workbench.alert.create(message, 'notice')
}
</script>

<style scoped>
:deep(.vue-autocomplete-list) {
  min-width: 700px;
}
</style>
