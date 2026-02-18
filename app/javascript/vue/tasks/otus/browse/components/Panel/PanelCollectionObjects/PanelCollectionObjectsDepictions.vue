<template>
  <div>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '500px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Depictions</h3>
      </template>
      <template #body>
        <div class="flex-wrap-row gap-small">
          <ImageViewer
            v-for="depiction in depictions"
            edit
            :depiction="depiction"
            :key="depiction.id"
          />
        </div>
      </template>
    </VModal>
    <VBtn
      color="primary"
      :disabled="!depictions.length"
      @click="() => (isModalVisible = true)"
    >
      Show ({{ depictions.length }})
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'

defineProps({
  depictions: {
    type: Array,
    required: true
  }
})

const isModalVisible = ref(false)
</script>
