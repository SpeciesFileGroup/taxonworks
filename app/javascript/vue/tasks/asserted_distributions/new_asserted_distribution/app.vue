<template>
  <div id="vue-task-asserted-distribution-new">
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
        <div>
          <span
            v-if="currentAssertedDistribution"
            v-html="currentAssertedDistribution.object_tag"
          />
          <span v-else>New record</span>
        </div>
        <div class="horizontal-center-content middle gap-small">
          <VBtn
            medium
            color="create"
            :disabled="!store.isSaveAvailable"
            @click="store.saveAssertedDistribution"
          >
            {{ store.assertedDistribution.id ? 'Update' : 'Create' }}
          </VBtn>

          <VBtn
            medium
            color="primary"
            @click="store.reset"
          >
            New
          </VBtn>
          <TaskPreferences
            v-model:autosave="autosave"
            :show-confidence="showConfidencePanel"
            @update:show-confidence="setConfidencePanelVisibility"
          />
        </div>
      </div>
    </NavBar>

    <div class="grid-panels gap-medium margin-medium-bottom">
      <PanelCitation />
      <PanelObject />
      <PanelGeo />
      <PanelConfidence v-if="showConfidencePanel" />
    </div>

    <TableComponent class="full_width" />
  </div>
</template>

<script setup>
import PanelObject from './components/Panel/PanelObject.vue'
import PanelGeo from './components/Panel/PanelGeo.vue'
import PanelCitation from './components/Panel/PanelCitation.vue'
import PanelConfidence from './components/Panel/PanelConfidence.vue'
import TableComponent from './components/table'
import TaskPreferences from './components/TaskPreferences.vue'
import VSpinner from '@/components/ui/VSpinner'
import NavBar from '@/components/layout/NavBar'
import platformKey from '@/helpers/getPlatformKey'

import { useHotkey, useUserPreference } from '@/composables'
import { computed, ref, onBeforeMount, watch } from 'vue'
import { useStore } from './store/store.js'

import VBtn from '@/components/ui/VBtn/index.vue'

const KEY_STORAGE_AUTOSAVE = 'Task::NewAssertedDistribution::Autosave'
const KEY_STORAGE_SHOW_CONFIDENCE =
  'Task::NewAssertedDistribution::ShowConfidencePanel'

defineOptions({
  name: 'NewAssertedDistribution'
})

const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      store.saveAssertedDistribution()
    }
  }
])

useHotkey(shortcuts.value)

const store = useStore()
const autosave = useUserPreference(KEY_STORAGE_AUTOSAVE, false)
const showConfidencePanel = useUserPreference(KEY_STORAGE_SHOW_CONFIDENCE, true)

function setConfidencePanelVisibility(isVisible) {
  showConfidencePanel.value = isVisible

  if (!isVisible) {
    store.clearConfidences()
  }
}

const currentAssertedDistribution = computed(() =>
  store.assertedDistributions.find(
    (item) => item.id === store.assertedDistribution.id
  )
)

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
  const urlParams = new URLSearchParams(window.location.search)
  const id = urlParams.get('asserted_distribution_id')

  store.loadRecentAssertedDistributions()

  if (id) {
    store.load(id)
  }

  TW.workbench.keyboard.createLegend(
    `${platformKey()}+s`,
    'Save and create new asserted distribution',
    'New asserted distribution'
  )
})
</script>

<style scoped>
.grid-panels {
  display: grid;
  grid-template-columns: 1fr 1fr 0.75fr;
}
</style>
