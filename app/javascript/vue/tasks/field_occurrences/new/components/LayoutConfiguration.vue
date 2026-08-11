<template>
  <VBtn
    icon
    medium
    variant="tonal"
    color="primary"
    title="Layout settings"
    @click="() => (isModalVisible = true)"
  >
    <IconSettings class="w-4 h-4" />
  </VBtn>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '500px' }"
    @close="handleClose"
  >
    <template #header>
      <h3>Layout settings</h3>
    </template>
    <template #body>
      <h3>Field occurrence form</h3>
      <ul class="no_bullets">
        <li
          v-for="({ title }, key) in VueComponents"
          :key="key"
        >
          <label>
            <input
              type="checkbox"
              :checked="!list.includes(key)"
              @change="(e) => handleToggle(key, e.target.checked)"
            />
            {{ title }}
          </label>
        </li>
      </ul>
      <h3 class="separate-top">Behavior</h3>
      <label class="middle horizontal-left-content gap-small">
        <input
          type="checkbox"
          v-model="settings.sortable"
        />
        Reorder fields
      </label>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useUserPreferences } from '@/composables'
import { KEY_STORAGE_HIDDEN } from '../constants/preferences'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import IconSettings from '@/components/Icon/IconSettings.vue'
import VueComponents from '../constants/components'
import useSettingStore from '../store/settings'

const settings = useSettingStore()
const { preferences, setPreference } = useUserPreferences()

const hiddenComponents = computed(
  () => preferences.value.layout?.[KEY_STORAGE_HIDDEN] || []
)

const list = ref([])
const isModalVisible = ref(false)

function handleClose() {
  isModalVisible.value = false
  setPreference(KEY_STORAGE_HIDDEN, list.value)
}

function handleToggle(key, checked) {
  list.value = checked
    ? list.value.filter((c) => c !== key)
    : [...list.value, key]
}

watch(hiddenComponents, (newVal) => (list.value = newVal), { immediate: true })
</script>
