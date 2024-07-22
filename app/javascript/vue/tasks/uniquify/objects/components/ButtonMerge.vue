<template>
  <VBtn
    color="destroy"
    :disabled="!keepGlobalId || !removeGlobalId"
    @click="mergeObjects"
  >
    Merge
  </VBtn>
  <VSpinner
    v-if="isSaving"
    full-screen
  />
  <ConfirmationModal ref="confirmationModalRef" />
  <VModal
    v-if="isModalVisible"
    :container-style="{ minWidth: '800px' }"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Merge stats</h3>
    </template>
    <template #body>
      <TableResponse :response="response" />
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { Unify } from '@/routes/endpoints'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import TableResponse from './TableResponse.vue'

const props = defineProps({
  keepGlobalId: {
    type: String,
    default: undefined
  },
  removeGlobalId: {
    type: String,
    default: undefined
  },
  only: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['merge'])

const confirmationModalRef = ref(null)
const isSaving = ref(false)
const isModalVisible = ref(false)
const response = ref({})

async function mergeObjects() {
  const ok = await confirmationModalRef.value.show({
    title: 'Merge',
    okButton: 'Merge',
    message: 'Are you sure you want to merge the objects?',
    confirmationWord: 'MERGE'
  })

  if (ok) {
    isSaving.value = true

    Unify.merge({
      remove_global_id: props.removeGlobalId,
      keep_global_id: props.keepGlobalId,
      only: props.only
    })
      .then(({ body }) => {
        emit('merge')
        response.value = body
        isModalVisible.value = true
      })
      .catch(() => {})
      .finally(() => {
        isSaving.value = false
      })
  }
}
</script>
