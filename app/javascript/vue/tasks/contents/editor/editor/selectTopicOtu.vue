<template>
  <div>
    <button
      @click="() => (isModalVisible = true)"
      class="button normal-input button-default"
    >
      Select
    </button>
    <VModal
      v-if="isModalVisible"
      :button-close="{
        disabled: !(store.topic && store.otu)
      }"
      @close="closeModal()"
    >
      <template #header>
        <h3>Select</h3>
      </template>
      <template #body>
        <div class="flex-wrap-column middle gap-small">
          <TopicModal />
          <OtuModal />
          <ContentModal />
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import useContentStore from '../store/store.js'
import VModal from '@/components/ui/Modal.vue'
import TopicModal from '../components/Topic/TopicModal.vue'
import OtuModal from '../components/Otu/OtuModal.vue'
import ContentModal from '../components/Content/ContentModal.vue'

const emit = defineEmits(['close'])

const store = useContentStore()
const isModalVisible = ref(true)

watch([() => store.otu, () => store.topic], ([newOtu, newTopic]) => {
  if (newOtu && newTopic) {
    isModalVisible.value = false
  }
})

function closeModal() {
  if (store.otu && store.topic) {
    isModalVisible.value = false
    emit('close')
  }
}
</script>
