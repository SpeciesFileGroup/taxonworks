<template>
  <VBtn
    medium
    color="primary"
    :disabled="disabled"
    @click="openModal"
  >
    Preview
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="closeModal"
  >
    <template #header>
      <h3>Preview response</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <PreviewTable :data="data" />
    </template>
    <template #footer>
      <div class="flex-separate middle">
        <VBtn
          color="create"
          medium
          @click="
            () => {
              emit('finalize')
              closeModal()
            }
          "
        >
          Finalize
        </VBtn>
        <VBtn
          color="primary"
          medium
          @click="closeModal"
        >
          Close
        </VBtn>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import PreviewTable from './PreviewTable.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  payload: {
    type: Object,
    required: true
  },

  batchService: {
    type: Function,
    required: true
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['finalize', 'close'])

const data = ref(null)
const isModalVisible = ref(false)
const isLoading = ref(false)

function makeBatchloadRequest() {
  isLoading.value = true
  props
    .batchService({ ...props.payload, preview: true })
    .then(({ body }) => {
      data.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}

function openModal() {
  isModalVisible.value = true
  makeBatchloadRequest()
}

function closeModal() {
  isModalVisible.value = false
  data.value = null
  emit('close')
}

defineExpose({
  openModal
})
</script>
