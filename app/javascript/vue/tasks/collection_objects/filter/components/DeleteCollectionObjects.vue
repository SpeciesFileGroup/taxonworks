<template>
  <ConfirmationModal ref="confirmationModal" />
  <VBtn
    color="primary"
    medium
    @click="openModal"
  >
    Delete collection objects
  </VBtn>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'

const CONFIRM_WORD = 'delete'
const MAX = 25

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['delete'])
const confirmationModal = ref(null)

function deleteCOs () {
  const ids = [...props.ids]
  const requests = ids.map(id => CollectionObject.destroy(id))

  Promise.all(requests).then(_ => {
    emit('delete', { ids })
  })
}

async function openModal () {
  const ok = await confirmationModal.value.show({
    title: 'Delete collection objects',
    message: `This will delete ${props.ids.length} collection objects. Are you sure you want to proceed?`,
    confirmationWord: 'DESTROY',
    okButton: 'Delete',
    cancelButton: 'Cancel',
    typeButton: 'delete'
  })

  if (ok) {
    deleteCOs()
  }
}

</script>
