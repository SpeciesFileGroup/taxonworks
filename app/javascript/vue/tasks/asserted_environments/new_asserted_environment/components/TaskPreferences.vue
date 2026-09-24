<template>
  <VBtn
    color="primary"
    medium
    @click="() => (isModalVisible = true)"
  >
    Preferences
  </VBtn>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '400px' }"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Preferences</h3>
    </template>
    <template #body>
      <label class="middle">
        <input
          type="checkbox"
          v-model="autosave"
        />
        Autosave when an environment is selected
      </label>
    </template>
  </VModal>
</template>

<script setup>
// Written with CLAUDE code
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'

const autosave = defineModel('autosave', {
  type: Boolean,
  default: false
})

const isModalVisible = ref(false)
</script>
