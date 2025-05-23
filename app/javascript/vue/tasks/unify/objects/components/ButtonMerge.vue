<template>
  <VBtn
    color="destroy"
    :disabled="
      !keepGlobalId ||
      !removeGlobalId ||
      disabled ||
      keepGlobalId === removeGlobalId
    "
    @click="mergeObjects"
  >
    Unify
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
      <h3>Unify stats</h3>
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

  remove: {
    type: Object,
    default: null
  },

  only: {
    type: Array,
    default: () => []
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['merge'])

const confirmationModalRef = ref(null)
const isSaving = ref(false)
const isModalVisible = ref(false)
const response = ref({})

async function mergeObjects() {
  const ok = await confirmationModalRef.value.show({
    title: 'Unify',
    okButton: 'Unify',
    message: 'Are you sure you want to unify the objects?',
    confirmationWord: 'UNIFY'
  })

  if (ok) {
    const payload = {
      remove_global_id: props.removeGlobalId,
      keep_global_id: props.keepGlobalId
    }

    if (props.only.length !== Object.keys(props.remove._metadata).length) {
      Object.assign(payload, { only: props.only })
    }

    isSaving.value = true

    Unify.merge(payload)
      .then(({ body }) => {
        if (body.result.unified) {
          emit('merge')
        }

        if (body.result.message) {
          TW.workbench.alert.create(body.result.message, 'error')
        } else {
          response.value = body
          isModalVisible.value = true
        }
      })
      .catch(() => {})
      .finally(() => {
        isSaving.value = false
      })
  }
}
</script>
