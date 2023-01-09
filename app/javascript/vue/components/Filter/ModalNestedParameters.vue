<template>
  <VModal
    v-if="isModalVisible"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Query parameters</h3>
    </template>
    <template #body>
      <pre v-text="JSON.stringify(queryParameters, null, 2)" />
    </template>
  </VModal>
  <VBtn
    v-if="queryParameters.length"
    color="primary"
    medium
    @click="isModalVisible = true"
  >
    Nested parameters
  </VBtn>
</template>

<script setup>
import { ref, computed } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  parameters: {
    type: Object,
    default: () => ({})
  }
})

const queryParameters = computed(() => {
  const params = Object.keys(props.parameters).filter(key => key.includes('query'))

  return params.map(param => ({ [param]: props.parameters[param] }))
})

const isModalVisible = ref(false)
</script>
