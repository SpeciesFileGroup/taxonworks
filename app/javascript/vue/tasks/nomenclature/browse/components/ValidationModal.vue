<template>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>Validations</template>
    <template #body>
      <SoftValidations
        :global-id="globalId"
        in-place
      />
    </template>
  </VModal>
</template>

<script setup>
import { ref, onBeforeUnmount, onMounted } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import SoftValidations from '@/components/soft_validations/objectValidation.vue'

const isModalVisible = ref(false)
const globalId = ref(null)
let elements = []

onMounted(() => {
  elements = [
    ...document.querySelectorAll('.taxonomic_history .soft_validation_anchor')
  ]

  elements.forEach((el) => el.addEventListener('click', handleClick))
})

onBeforeUnmount(() =>
  elements.forEach((el) => el.removeEventListener('click', handleClick))
)

function handleClick(e) {
  const el = e.target

  globalId.value = el.getAttribute('data-global-id')
  isModalVisible.value = true
}
</script>
