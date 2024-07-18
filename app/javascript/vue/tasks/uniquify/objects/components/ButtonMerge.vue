<template>
  <VBtn
    color="destroy"
    :disabled="!keepGlobalId || !removeGlobalId"
    @click="mergeObjects"
  >
    Merge
  </VBtn>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { ref } from 'vue'
import { Unify } from '@/routes/endpoints'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  keepGlobalId: {
    type: String,
    default: undefined
  },
  removeGlobalId: {
    type: String,
    default: undefined
  }
})

const confirmationModalRef = ref(null)
const isSaving = ref(null)

async function mergeObjects() {
  isSaving.value = true

  const ok = await confirmationModalRef.value.show({
    title: 'Merge',
    okButton: 'Merge',
    message: 'Are you sure you want to merge the objects?',
    confirmationWord: 'merge'
  })

  if (ok) {
    Unify.merge({
      remove_global_id: props.removeGlobalId,
      keep_global_id: props.keepGlobalId
    })
      .catch(() => {})
      .finally(() => {
        isSaving.value = false
      })
  }
}
</script>
