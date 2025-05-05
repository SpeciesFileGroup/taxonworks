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
        disabled: !(topic && otu)
      }"
      @close="closeModal()"
    >
      <template #header>
        <h3>Select</h3>
      </template>
      <template #body>
        <div class="flex-wrap-column middle">
          <TopicModal />
          <OtuModal />
          <ContentModal />
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { useStore } from 'vuex'
import { computed, ref, watch } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import TopicModal from '../components/Topic/TopicModal.vue'
import OtuModal from '../components/Otu/OtuModal.vue'
import ContentModal from '../components/Content/ContentModal.vue'

const emit = defineEmits(['close'])

const store = useStore()
const isModalVisible = ref(true)

const topic = computed(() => store.getters[GetterNames.GetTopicSelected])
const otu = computed(() => store.getters[GetterNames.GetOtuSelected])

watch([otu, topic], ([newOtu, newTopic]) => {
  if (newOtu && newTopic) {
    isModalVisible.value = false
  }
})

function closeModal() {
  if (otu.value && topic.value) {
    isModalVisible.value = false
    emit('close')
  }
}
</script>
