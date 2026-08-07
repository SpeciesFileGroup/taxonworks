<template>
  <div class="flex-separate middle">
    <h1>New field occurrence</h1>
    <ul class="context-menu">
      <li>
        <LayoutConfiguration
          :hidden="hiddenComponents"
          @update="(list) => setPreference(KEY_STORAGE_HIDDEN, list)"
        />
      </li>
      <li>
        <label>
          <input
            type="checkbox"
            v-model="settings.sortable"
          />
          Reorder fields
        </label>
      </li>
    </ul>
  </div>
  <div>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <HeaderBar />
    <div class="horizontal-left-content align-start gap-medium">
      <VDraggable
        class="flex-wrap-column gap-medium left-column"
        v-model="layout"
        :item-key="(element) => element"
        :disabled="!settings.sortable"
        @end="updatePreferences"
      >
        <template #item="{ element }">
          <component
            v-if="!hiddenComponents?.includes(element)"
            :is="VueComponents[element]?.component"
          />
        </template>
      </VDraggable>

      <CollectingEventForm class="right-column" />
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useUserPreferences } from '@/composables'
import VDraggable from 'vuedraggable'
import HeaderBar from './components/HeaderBar.vue'
import CollectingEventForm from './components/CollectingEventForm.vue'
import useSettingStore from './store/settings'
import VueComponents from './constants/components'
import VSpinner from '@/components/ui/VSpinner.vue'
import LayoutConfiguration from './components/LayoutConfiguration.vue'

const KEY_STORAGE = 'task::FieldOccurrence::Form::ComponentsOrder'
const KEY_STORAGE_HIDDEN = 'task::FieldOccurrence::Form::ComponentsHidden'

const layout = ref(Object.keys(VueComponents))
const { preferences, loadPreferences, setPreference } = useUserPreferences()

defineOptions({
  name: 'NewFieldOccurrence'
})

const settings = useSettingStore()
const isLoading = ref(true)
const hiddenComponents = computed(
  () => preferences.value.layout?.[KEY_STORAGE_HIDDEN] || []
)

function updatePreferences() {
  setPreference(KEY_STORAGE, layout.value)
}

loadPreferences()
  .then(() => {
    const layoutStored = preferences.value.layout[KEY_STORAGE]

    if (
      layoutStored?.length === layout.value.length &&
      layout.value.every((c) => layoutStored.includes(c))
    ) {
      layout.value = layoutStored
    }
  })
  .finally(() => {
    isLoading.value = false
  })
</script>

<style scoped>
.left-column {
  max-width: 25%;
  min-width: 500px;
}

.right-column {
  display: flex;
  flex-grow: 2;
}
</style>
