<template>
  <VBtn
    color="primary"
    medium
    @click="openModal"
  >
    Settings
  </VBtn>
  <VModal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Settings</h3>
    </template>
    <template #body>
      Truncate labels at max length:
      <input
        type="number"
        ref="inputRef"
        v-between-numbers="[0, 100]"
        v-model="store.truncateMaxLength"
        @keydown.enter="() => (isModalVisible = false)"
      />
    </template>
  </VModal>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import { useContainerStore } from '../store'
import { vBetweenNumbers } from '@/directives'
import { ref, nextTick } from 'vue'

const inputRef = ref(null)
const isModalVisible = ref(false)
const store = useContainerStore()

function openModal() {
  isModalVisible.value = true

  nextTick(() => {
    inputRef.value.focus()
  })
}
</script>

<style scoped>
input[type='number'] {
  width: 60px;
}
</style>
