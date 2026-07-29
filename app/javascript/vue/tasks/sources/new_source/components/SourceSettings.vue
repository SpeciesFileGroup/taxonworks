<template>
  <VBtn
    icon
    medium
    variant="tonal"
    color="primary"
    title="Settings"
    @click="showModal = true"
  >
    <IconSettings class="w-4 h-4" />
  </VBtn>
  <VModal
    v-if="showModal"
    @close="showModal = false"
    :container-style="{ width: '500px' }"
  >
    <template #header>
      <h3>Settings</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li>
          <label class="middle horizontal-left-content gap-small">
            <input
              type="checkbox"
              v-model="autosave"
            />
            Autosave
          </label>
        </li>
        <li>
          <label
            v-help.sections.global.reorderFields
            class="middle horizontal-left-content gap-small"
          >
            <input
              type="checkbox"
              v-model="settings.sortable"
            />
            Reorder fields
          </label>
        </li>
      </ul>
    </template>
  </VModal>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useSettingStore } from '../store'
import { useUserPreference } from '@/composables'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import IconSettings from '@/components/Icon/IconSettings.vue'

const KEY_STORAGE_AUTOSAVE = 'task::NewSource::Autosave'

const settings = useSettingStore()
const autosave = useUserPreference(KEY_STORAGE_AUTOSAVE, settings.autosave)
const showModal = ref(false)

watch(
  autosave,
  (value) => {
    settings.autosave = value
  },
  { immediate: true }
)
</script>
