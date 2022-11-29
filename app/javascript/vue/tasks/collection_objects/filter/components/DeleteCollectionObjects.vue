<template>
  <div>
    <ConfirmationModal ref="confirmationModal" />
    <VBtn
      color="primary"
      medium
      :disabled="disabled"
      @click="openModal"
    >
      Delete collection objects
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'

const CONFIRM_WORD = 'DELETE'
const MAX = 25
const MIN_CONFIRM = 5

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['delete'])
const confirmationModal = ref(null)

function deleteCOs () {
  let failedCount = 0
  const ids = [...props.ids]
  const destroyedIds = []
  const requests = ids.map(id =>
    CollectionObject.destroy(id)
      .then(_ => destroyedIds.push(id))
      .catch(_ => failedCount++)
  )

  Promise.allSettled(requests).then(_ => {
    const message = failedCount
      ? `Deleted: ${destroyedIds.length} object(s). Failed to delete: ${failedCount}`
      : `Deleted: ${destroyedIds.length} object(s).`

    TW.workbench.alert.create(message, 'notice')
    emit('delete', destroyedIds)
  })
}

async function openModal () {
  if (props.ids.length > MAX) {
    TW.workbench.alert.create(`Select a maximum of ${MAX} objects to delete.`, 'error')

    return
  }

  const ok = await confirmationModal.value.show({
    title: 'Delete collection objects',
    message: `This will delete ${props.ids.length} collection objects. Are you sure you want to proceed?`,
    confirmationWord: props.ids.length >= MIN_CONFIRM ? CONFIRM_WORD : '',
    okButton: 'Delete',
    cancelButton: 'Cancel',
    typeButton: 'delete'
  })

  if (ok) {
    deleteCOs()
  }
}

</script>
