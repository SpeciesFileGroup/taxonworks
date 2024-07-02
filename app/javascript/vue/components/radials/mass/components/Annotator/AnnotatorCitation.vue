<template>
  <div class="confidence_annotator">
    <VSpinner v-if="isCreating" />
    <FormCitation
      :target="objectType"
      v-model="citation"
      :submit-button="{
        label: 'Create',
        color: 'create'
      }"
      @submit="createCitation"
    />
    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Citation } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import confirmationOpts from '../../constants/confirmationOpts.js'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['create'])

const confirmationModalRef = ref(null)
const citation = ref({})
const isCreating = ref(false)

async function createCitation() {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    isCreating.value = true
    Citation.createBatch({
      citation_object_type: props.objectType,
      source_id: citation.value.source_id,
      pages: citation.value.pages,
      citation_object_id: props.ids
    })
      .then(({ body }) => {
        TW.workbench.alert.create(
          'Citation(s) were successfully created',
          'notice'
        )
        emit('create', body)
      })
      .catch(() => {})
      .finally(() => {
        isCreating.value = false
      })
  }
}
</script>
