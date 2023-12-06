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
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Preview</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <PreviewTable :data="data" />
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
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
</script>
