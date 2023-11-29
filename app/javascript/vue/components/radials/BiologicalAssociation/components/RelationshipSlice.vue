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
        <legend>Biological relationship</legend>
        <SmartSelector
          model="biological_relationships"
          :klass="BIOLOGICAL_ASSOCIATION"
          :target="BIOLOGICAL_ASSOCIATION"
          @selected="(item) => (biologicalAssociation = item)"
        />
        <SmartSelectorItem
          :item="biologicalAssociation"
          label="name"
          @unset="biologicalAssociation = undefined"
        />
      </fieldset>

      <VBtn
        class="margin-large-top"
        color="create"
        medium
        :disabled="!biologicalAssociation || isCountExceeded"
        @click="handleUpdate"
      >
        Update
      </VBtn>

      <ConfirmationModal ref="confirmationModalRef" />
    </div>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/spinner.vue'
import { BiologicalAssociation } from '@/routes/endpoints'
import { BIOLOGICAL_ASSOCIATION } from '@/constants/index.js'
import { computed, ref } from 'vue'

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

const biologicalAssociation = ref()
const confirmationModalRef = ref(null)
const isUpdating = ref(false)
const batchResponse = ref({
  updated: [],
  not_updated: []
})

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

function changeRelationship() {
  const payload = {
    biological_association_query: props.parameters,
    biological_association: {
      biological_relationship_id: biologicalAssociation.value.id
    }
  }

  isUpdating.value = true

  BiologicalAssociation.batchUpdate(payload)
    .then(({ body }) => {
      const message = body.updated.length
        ? `${body.updated.length} biological association(s) were successfully updated.`
        : 'No biological associations were updated.'

      batchResponse.value = body

      TW.workbench.alert.create(message, 'notice')
    })
    .catch(() => {})
    .finally(() => {
      isUpdating.value = false
    })
}

async function handleUpdate() {
  const ok = await confirmationModalRef.value.show({
    title: 'Change relationship',
    message:
      'This will change the relationship for the selected biological associations. Are you sure you want to proceed?',
    confirmationWord: 'CHANGE',
    okButton: 'Update',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    changeRelationship()
  }
}
</script>
