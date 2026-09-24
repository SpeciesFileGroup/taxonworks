<template>
  <div id="vue-task-asserted-environment-new">
    <VSpinner
      v-if="store.isLoading"
      full-screen
      legend="Loading..."
    />

    <VSpinner
      v-if="store.isSaving"
      full-screen
      legend="Saving..."
    />
    <NavBar
      class="margin-medium-bottom"
      navbar-class="panel content rounded-tl-none rounded-tr-none"
    >
      <div class="flex-separate middle">
        <span>New record</span>
        <div class="horizontal-center-content middle gap-small">
          <VBtn
            medium
            color="create"
            :disabled="!store.isSaveAvailable"
            @click="store.saveAssertedEnvironment"
          >
            Create
          </VBtn>

          <VBtn
            medium
            color="primary"
            @click="store.reset"
          >
            New
          </VBtn>
          <TaskPreferences v-model:autosave="autosave" />
        </div>
      </div>
    </NavBar>

    <div class="grid-panels gap-medium margin-medium-bottom">
      <PanelCitation
        v-model="store.citation"
        v-model:lock="store.lock.source"
        :target="ASSERTED_ENVIRONMENT"
      />
      <PanelObject />
      <PanelEnvironment />
    </div>

    <TableAssertedEnvironments class="full_width" />
  </div>
</template>

<script setup>
// Written with CLAUDE code
import { onBeforeMount, ref, watch } from 'vue'
import { useHotkey, useUserPreference } from '@/composables'
import { ASSERTED_ENVIRONMENT } from '@/constants'
import { useStore } from './store/store.js'
import platformKey from '@/helpers/getPlatformKey'
import PanelCitation from '@/components/Form/FormCitation/PanelCitation.vue'
import PanelObject from './components/Panel/PanelObject.vue'
import PanelEnvironment from './components/Panel/PanelEnvironment.vue'
import TableAssertedEnvironments from './components/TableAssertedEnvironments.vue'
import TaskPreferences from './components/TaskPreferences.vue'
import VSpinner from '@/components/ui/VSpinner'
import NavBar from '@/components/layout/NavBar'
import VBtn from '@/components/ui/VBtn/index.vue'

const KEY_STORAGE_AUTOSAVE = 'Task::NewAssertedEnvironment::Autosave'

const store = useStore()
const autosave = useUserPreference(KEY_STORAGE_AUTOSAVE, false)

const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      store.saveAssertedEnvironment()
    }
  }
])

defineOptions({
  name: 'NewAssertedEnvironment'
})

useHotkey(shortcuts.value)

watch(
  autosave,
  (newVal) => {
    store.autosave = newVal
  },
  {
    immediate: true
  }
)

onBeforeMount(() => {
  store.loadRecentAssertedEnvironments()

  TW.workbench.keyboard.createLegend(
    `${platformKey()}+s`,
    'Save and create new asserted environment',
    'New asserted environment'
  )
})
</script>

<style scoped>
.grid-panels {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
}
</style>
