<template>
  <VBtn
    medium
    color="primary"
    icon
    variant="tonal"
    title="Task settings"
    @click="() => (isModalVisible = true)"
  >
    <IconSettings class="w-4 h-4" />
  </VBtn>
  <Modal
    v-if="isModalVisible"
    @close="() => (isModalVisible = false)"
  >
    <template #header>
      <h3>Task settings</h3>
    </template>
    <template #body>
      <label
        v-help.section.navbar.autosave
        class="horizontal-left-content middle gap-small"
      >
        <input
          type="checkbox"
          v-model="isAutosaveActive"
        />
        Autosave
      </label>
    </template>
  </Modal>
</template>

<script setup>
import Modal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconSettings from '@/components/Icon/IconSettings.vue'
import { useUserPreference } from '@/composables'
import { MutationNames } from '../store/mutations/mutations'
import { ref, watch } from 'vue'
import { useStore } from 'vuex'

const KEY_STORAGE_AUTOSAVE = 'task::NewTaxonName::Autosave'

const store = useStore()
const isModalVisible = ref(false)
const isAutosaveActive = useUserPreference(KEY_STORAGE_AUTOSAVE, true)

watch(
  isAutosaveActive,
  (value) => store.commit(MutationNames.SetAutosave, value),
  { immediate: true }
)
</script>
