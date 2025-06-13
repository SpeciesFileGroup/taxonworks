<template>
  <VBtn
    medium
    color="create"
    :disabled="disabled"
    @click="openModal"
  >
    {{ buttonLabel }}
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="closeModal"
  >
    <template #header>
      <h3>Update response</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <PreviewTable
        v-if="data"
        :data="data"
      />
    </template>
  </VModal>
  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import PreviewTable from './PreviewTable.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'

const props = defineProps({
  payload: {
    type: Object,
    required: true
  },

  batchService: {
    type: Function,
    required: true
  },

  confirmationWord: {
    type: String,
    default: 'CHANGE'
  },

  disabled: {
    type: Boolean,
    default: false
  },

  buttonLabel: {
    type: String,
    default: 'Update'
  }
})

const emit = defineEmits(['update', 'close'])

const data = ref(null)
const isModalVisible = ref(false)
const isLoading = ref(false)
const confirmationModalRef = ref(null)

function makeBatchloadRequest() {
  isLoading.value = true
  props
    .batchService(props.payload)
    .then(({ body }) => {
      emit('update', body)
      data.value = body
    })
    .catch(() => {
      isModalVisible.value = false
    })
    .finally(() => {
      isLoading.value = false
    })
}

function openModal() {
  isModalVisible.value = true
  handleUpdate()
}

function closeModal() {
  isModalVisible.value = false
  data.value = null
  emit('close')
}

async function handleUpdate() {
  const ok = await confirmationModalRef.value.show({
    title: 'Batch update',
    message: 'Are you sure you want to proceed?',
    confirmationWord: props.confirmationWord,
    okButton: props.buttonLabel,
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    makeBatchloadRequest()
  } else {
    isModalVisible.value = false
  }
}

defineExpose({
  openModal
})
</script>
