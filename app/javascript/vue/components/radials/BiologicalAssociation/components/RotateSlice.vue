<template>
  <div>
    <VBtn
      color="create"
      medium
      @click="handleUpdate"
    >
      Rotate
    </VBtn>
    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { BiologicalAssociation } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const confirmationModalRef = ref(null)
const batchResponse = ref({
  updated: [],
  not_updated: []
})

function rotateBiologicalAssociations() {
  const payload = {
    biological_association_query: props.parameters
  }

  BiologicalAssociation.batchRotate(payload).then(({ body }) => {
    const message = body.updated.length
      ? `${body.updated.length} biological association(s) were successfully updated.`
      : 'No biological associations were updated.'

    batchResponse.value = body

    TW.workbench.alert.create(message, 'notice')
  })
}

async function handleUpdate() {
  const ok = await confirmationModalRef.value.show({
    title: 'Rotate biological association',
    message:
      'This will change rotate the biological association. Are you sure you want to proceed?',
    confirmationWord: 'ROTATE',
    okButton: 'Update',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    rotateBiologicalAssociations()
  }
}
</script>
