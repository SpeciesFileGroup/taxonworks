<template>
  <VBtn
    medium
    color="create"
    :disabled="disabled"
    @click="openModal"
  >
    Update
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
      <PreviewTable :data="data" />
    </template>
    <template #footer>
      <div class="horizontal-right-content">
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
import VSpinner from '@/components/spinner.vue'

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

const emit = defineEmits(['update'])

const data = ref(null)
const isModalVisible = ref(false)
const isLoading = ref(false)

function makeBatchloadRequest() {
  isLoading.value = true
  props
    .batchService(props.payload)
    .then(({ body }) => {
      emit('update', body)
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
}

defineExpose({
  openModal
})
</script>
