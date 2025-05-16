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
    :container-style="{ width: '600px', height: '70vh' }"
  >
    <template #header>
      <h3>Select OTU</h3>
    </template>
    <template #body>
      <SmartSelector
        model="otus"
        target="Content"
        klass="Content"
        @selected="setOtu"
      />
    </template>
  </VModal>
</template>

<script setup>
import { ref, computed } from 'vue'
import useContentStore from '../../store/store.js'
import VModal from '@/components/ui/Modal.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'

const store = useContentStore()
const isModalVisible = ref(false)

const buttonLabel = computed(() => (store.otu ? 'Change OTU' : 'OTU'))

function setOtu(otu) {
  store.otu = otu
  isModalVisible.value = false
}
</script>
