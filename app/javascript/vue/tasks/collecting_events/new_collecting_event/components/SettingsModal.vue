<template>
  <VBtn
    icon
    medium
    color="primary"
    variant="tonal"
    title="Settings"
    @click="() => (isModalVisible = true)"
  >
    <IconSettings class="w-4 h-4" />
  </VBtn>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '500px' }"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Settings</h3>
    </template>
    <template #body>
      <label class="middle horizontal-left-content gap-small">
        <input
          type="checkbox"
          :checked="sortable"
          @change="(e) => (sortable = e.target.checked)"
        />
        Reorder fields
      </label>
      <p class="subtle">
        When active, drag to reorder the fields of the collecting event form.
      </p>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import IconSettings from '@/components/Icon/IconSettings.vue'

const sortable = defineModel('sortable', {
  type: Boolean,
  default: false
})

const isModalVisible = ref(false)
</script>
