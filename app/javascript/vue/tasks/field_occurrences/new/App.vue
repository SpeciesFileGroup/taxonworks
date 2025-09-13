<template>
  <div class="flex-separate middle">
    <h1>New field occurrence</h1>
    <label>
      <input
        type="checkbox"
        v-model="settings.sortable"
      />
      Reorder fields
    </label>
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
          <component :is="VueComponents[element]" />
        </template>
      </VDraggable>

      <CollectingEventForm class="right-column" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { User } from '@/routes/endpoints'
import VDraggable from 'vuedraggable'
import HeaderBar from './components/HeaderBar.vue'
import CollectingEventForm from './components/CollectingEventForm.vue'
import useSettingStore from './store/settings'
import VueComponents from './constants/components'
import VSpinner from '@/components/ui/VSpinner.vue'
const KEY_STORAGE = 'FieldOccurrence::Form::ComponentsOrder'

const layout = ref(Object.keys(VueComponents))

defineOptions({
  name: 'NewFieldOccurrence'
})

const settings = useSettingStore()
const isLoading = ref(true)

const preferences = ref({})

function updatePreferences() {
  User.update(preferences.value.id, {
    user: { layout: { [KEY_STORAGE]: layout.value } }
  }).then(({ body }) => {
    preferences.value.layout = body.preferences
    layout.value = body.preferences.layout[KEY_STORAGE]
  })
}

User.preferences()
  .then((response) => {
    preferences.value = response.body

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
