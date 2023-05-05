<template>
  <VModal
    v-if="isModalVisible"
    :container-style="{ maxWidth: '800px', width: 'auto' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Related biological associations</h3>
    </template>

    <template #body>
      <ul>
        <li
          v-for="item in biologicalAssociations"
          :key="item.id"
          v-html="item.object_tag"
        />
      </ul>
    </template>
  </VModal>
  <VBtn
    color="primary"
    :disabled="!biologicalAssociations.length"
    @click="isModalVisible = true"
  >
    Related ({{ biologicalAssociations.length }})
  </VBtn>
</template>

<script setup>
import { ref } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'

defineProps({
  biologicalAssociations: {
    type: Array,
    default: () => []
  }
})

const isModalVisible = ref(false)
</script>
