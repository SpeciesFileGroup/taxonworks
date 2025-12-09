<template>
  <div>
    <VBtn
      color="destroy"
      medium
      title="Convert this collection object to a field occurrence"
      :disabled="!collectionObject"
      @click="() => convertToFieldOccurrence(collectionObject)"
    >
      To field occurrence
    </VBtn>
    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { FieldOccurrence } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const props = defineProps({
  collectionObject: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['delete'])

const confirmationModalRef = ref()
const isLoading = ref(false)

async function convertToFieldOccurrence(collectionObject) {
  const keys = [
    'buffered_collecting_event',
    'buffered_determinations',
    'buffered_other_labels'
  ]

  const bufferedFields = keys.filter((key) => collectionObject[key])

  let message =
    'This will convert the collection object to a field occurrence. The original collection object will be deleted. This action cannot be undone.'

  if (bufferedFields.length > 0) {
    message += `<div class="feedback feedback-warning margin-medium-top">WARNING: This collection object has buffered data that will be lost: ${bufferedFields.join(
      ', '
    )}.</div>`
  }

  const ok = await confirmationModalRef.value.show({
    title: 'Convert to Field Occurrence',
    message,
    okButton: 'Convert',
    confirmationWord: 'CONVERT',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    isLoading.value = true

    try {
      const { body } = await FieldOccurrence.fromCollectionObject({
        collection_object_id: collectionObject.id
      })

      emit('convert', { collectionObject, fieldOccurrence: body })

      window.location.href = `${RouteNames.NewFieldOccurrence}?field_occurrence_id=${body.field_occurrence_id}`
    } catch (error) {
      const errorMessage =
        error?.response?.body?.error || 'Failed to convert to field occurrence'

      TW.workbench.alert.create(errorMessage, 'error')
    } finally {
      isLoading.value = false
    }
  }
}
</script>
