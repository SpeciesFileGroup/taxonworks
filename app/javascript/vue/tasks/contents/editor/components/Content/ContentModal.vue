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
    :container-style="{ width: '600px', height: '70vh' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Select Content</h3>
    </template>
    <template #body>
      <SmartSelector
        model="contents"
        :extend="['otu', 'topic']"
        @selected="setContent"
      />
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import useContentStore from '../../store/store.js'

const store = useContentStore()

const isModalVisible = ref(false)

const buttonLabel = computed(() =>
  store.content.id ? 'Change Content' : 'Content'
)

function setContent(content) {
  store.setContent(content)

  store.otu = content.otu
  store.topic = content.topic

  isModalVisible.value = false
}
</script>
