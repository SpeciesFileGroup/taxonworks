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
      <div class="flex-wrap-column gap-small">
        <label class="middle">
          <input
            type="checkbox"
            :checked="autosave"
            @change="(e) => emit('update:autosave', e.target.checked)"
          />
          Autosave
        </label>
        <label class="middle">
          <input
            type="checkbox"
            :checked="showConfidence"
            @change="(e) => emit('update:showConfidence', e.target.checked)"
          />
          Show confidence panel
        </label>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'

defineProps({
  autosave: {
    type: Boolean,
    default: false
  },

  showConfidence: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:autosave', 'update:showConfidence'])

const isModalVisible = ref(false)
</script>
