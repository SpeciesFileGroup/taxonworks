<template>
  <div>
    <p>
      <i>Marks or removes fossil status for all taxon names in the current filter result.</i>
    </p>
    <fieldset>
      <legend>Action</legend>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              name="fossil_mode"
              value="add"
              v-model="selectedMode"
            />
            Add fossil status
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              name="fossil_mode"
              value="remove"
              v-model="selectedMode"
            />
            Remove fossil status
          </label>
        </li>
      </ul>
    </fieldset>

    <div
      class="horizontal-left-content gap-small margin-large-top margin-large-bottom"
    >
      <VBtn
        color="primary"
        :disabled="!selectedMode"
        @click="openModal"
      >
        {{ selectedMode === 'add' ? 'Add fossil' : 'Remove fossil' }}
      </VBtn>
    </div>

    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />

    <VSpinner
      v-if="isProcessing"
      legend="Updating..."
    />
  </div>
</template>

<script setup>
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { TaxonNameClassification } from '@/routes/endpoints'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { TAXON_NAME } from '@/constants'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const confirmationModalRef = ref(null)
const selectedMode = ref(null)
const isProcessing = ref(false)

async function openModal() {
  const actionLabel = selectedMode.value === 'add' ? 'ADD' : 'REMOVE'
  const ok = await confirmationModalRef.value.show({
    title: 'Fossil status',
    message: `Are you sure you want to ${selectedMode.value} fossil status for all taxon names in the filter result?`,
    confirmationWord: actionLabel,
    okButton: actionLabel,
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (!ok) return

  const payload = {
    filter_query: { [QUERY_PARAM[TAXON_NAME]]: props.parameters },
    mode: selectedMode.value,
    params: {}
  }

  isProcessing.value = true
  TaxonNameClassification.batchByFilter(payload)
    .then(({ body }) => {
      const count = body.async
        ? body.total_attempted
        : body.updated.length

      const message = body.async
        ? `${count} taxon names queued for fossil status update.`
        : `Fossil status ${selectedMode.value === 'add' ? 'added to' : 'removed from'} ${count} taxon names.`

      TW.workbench.alert.create(message, 'notice')
      emit('close')
    })
    .finally(() => {
      isProcessing.value = false
    })
}
</script>
