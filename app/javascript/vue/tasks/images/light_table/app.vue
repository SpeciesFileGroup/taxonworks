<template>
  <div class="margin-medium-top">
    <VSpinner
      v-if="store.isLoading"
      full-screen
      legend="Loading light table..."
    />
    <VSpinner
      v-if="store.isSaving"
      full-screen
      legend="Saving light table..."
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
import qs from 'qs'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { useBeforeUnloadListener } from '@/composables'
import { LinkerStorage } from '@/shared/Filter/utils'
import useStore from './store/store'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import LayoutPicker from './components/picker/LayoutPicker.vue'
import LightTableEditor from './components/LightTableEditor.vue'

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

onBeforeMount(async () => {
  const { composition_id: compositionId, ...params } = {
    ...qs.parse(window.location.search, {
      ignoreQueryPrefix: true,
      arrayLimit: 2500
    }),
    ...(LinkerStorage.getParameters() || {})
  }

  LinkerStorage.removeParameters()

  if (Object.keys(params).length) {
    imageQuery.value = params
    history.replaceState(null, null, RouteNames.LightTable)
  }

  if (compositionId) await openComposition(compositionId)

  isReady.value = true
})
</script>
