<template>
  <div>
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
    <LightTableEditor
      v-if="isReady"
      :key="store.sessionKey"
      :image-query="imageQuery"
      @open="isPickerVisible = true"
      @new="newComposition"
      @image-query-loaded="imageQuery = null"
    />
    <VModal
      v-if="isPickerVisible"
      :container-style="{ width: '800px', maxWidth: '90vw' }"
      @close="isPickerVisible = false"
    >
      <template #header>
        <h3>Open a light table</h3>
      </template>
      <template #body>
        <LayoutPicker
          @select="({ id }) => openComposition(id)"
          @destroyed="onDestroyed"
        />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { useBeforeUnloadListener } from '@/composables'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import useStore from './store/store'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import LayoutPicker from './components/picker/LayoutPicker.vue'
import LightTableEditor from './components/LightTableEditor.vue'

const TASK = 'Light table'

const UNSAVED_MESSAGE =
  'You have unsaved changes. Are you sure you want to leave?'

const store = useStore()

const imageQuery = ref(null)
const isReady = ref(false)
const isPickerVisible = ref(false)

useBeforeUnloadListener({ show: computed(() => store.hasChanges) })

watch(
  () => store.composition?.id,
  (id) => setParam(RouteNames.LightTable, 'composition_id', id)
)

function confirmLeave() {
  return !store.hasChanges || window.confirm(UNSAVED_MESSAGE)
}

function openComposition(id) {
  if (!confirmLeave()) return

  isPickerVisible.value = false

  return store.loadComposition(id).catch(() => {})
}

function newComposition() {
  if (confirmLeave()) store.reset()
}

function onDestroyed(id) {
  if (store.composition?.id === id) store.reset()
}

function addShortcutsDescription() {
  TW.workbench.keyboard.createLegend('space', 'Hold to pan the table', TASK)
  TW.workbench.keyboard.createLegend(
    'del',
    'Remove selected images from the table',
    TASK
  )
  TW.workbench.keyboard.createLegend('esc', 'Clear selection', TASK)
  TW.workbench.keyboard.createLegend('ctrl+a', 'Select all images', TASK)
}

onBeforeMount(async () => {
  addShortcutsDescription()

  const { composition_id: compositionId, ...params } =
    useQueryParam().parameters

  if (Object.keys(params).length) {
    imageQuery.value = params
    history.replaceState(null, null, RouteNames.LightTable)
  }

  if (compositionId) await openComposition(compositionId)

  isReady.value = true
})
</script>
