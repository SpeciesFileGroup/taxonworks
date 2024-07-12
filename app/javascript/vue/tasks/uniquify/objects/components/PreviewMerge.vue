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
      @close="() => (isModalVisible = false)"
    >
      <template #header> Preview </template>
      <template #body><div></div> </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Unify } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  keepGlobalId: {
    type: [String, null],
    required: true
  },
  removeGlobalId: {
    type: [Object, null],
    required: true
  }
})

const isModalVisible = ref(false)

function openModal() {
  isModalVisible.value = true

  Unify.merge({
    remove_global_id: props.removeGlobalId,
    keep_global_id: props.keepGlobalId,
    preview: true
  })
    .then(({ body }) => {
      console.log(body)
    })
    .catch(() => {})
}
</script>
