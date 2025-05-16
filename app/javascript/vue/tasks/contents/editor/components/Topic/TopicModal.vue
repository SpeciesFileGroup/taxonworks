<template>
  <button
    type="button"
    class="button button-default button-select"
    @click="isModalVisible = true"
  >
    {{ buttonLabel }}
  </button>

  <VModal
    v-if="isModalVisible"
    @close="isModalVisible = false"
    :containerStyle="{ width: '600px', height: '70vh' }"
  >
    <template #header>
      <h3>Select Topic</h3>
    </template>
    <template #body>
      <TopicList @select="setTopic" />
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import TopicList from './TopicList.vue'
import useContentStore from '../../store/store.js'

const store = useContentStore()
const isModalVisible = ref(false)

const buttonLabel = computed(() => (store.topic ? 'Change Topic' : 'Topic'))

function setTopic(topic) {
  store.topic = topic
  isModalVisible.value = false
}
</script>
