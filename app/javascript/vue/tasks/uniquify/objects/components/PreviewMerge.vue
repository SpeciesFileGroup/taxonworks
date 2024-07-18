<template>
  <div>
    <VBtn
      color="primary"
      :disabled="!keepGlobalId || !removeGlobalId"
      @click="openModal"
    >
      Preview
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{ minWidth: '800px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Preview</h3>
      </template>
      <template #body>
        <VSpinner v-if="isLoading" />
        <TableResponse :response="previewResponse" />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Unify } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
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
  }
})

const isModalVisible = ref(false)
const previewResponse = ref({})
const isLoading = ref(false)

function openModal() {
  isModalVisible.value = true
  isLoading.value = true
  previewResponse.value = {}

  Unify.merge({
    remove_global_id: props.removeGlobalId,
    keep_global_id: props.keepGlobalId,
    preview: true
  })
    .then(({ body }) => {
      previewResponse.value = body
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}
</script>
