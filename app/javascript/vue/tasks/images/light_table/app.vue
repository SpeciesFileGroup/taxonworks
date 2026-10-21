<template>
  <div class="margin-medium-top">
    <VSpinner
      v-if="store.isLoading"
      full-screen
      legend="Loading light table..."
    />
    <LightTableEditor
      v-if="store.composition"
      :key="store.composition.id"
      :image-query="imageQuery"
      @close="closeComposition"
    />
    <LayoutPicker
      v-else
      @select="({ id }) => openComposition(id)"
    />
  </div>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import qs from 'qs'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { useBeforeUnloadListener } from '@/composables'
import { LinkerStorage } from '@/shared/Filter/utils'
import useStore from './store/store'
import VSpinner from '@/components/ui/VSpinner.vue'
import LayoutPicker from './components/picker/LayoutPicker.vue'
import LightTableEditor from './components/LightTableEditor.vue'

const store = useStore()

const imageQuery = ref(null)

useBeforeUnloadListener({ show: computed(() => store.hasChanges) })

function openComposition(id) {
  store
    .loadComposition(id)
    .then(() => {
      setParam(RouteNames.LightTable, 'composition_id', id)
    })
    .catch(() => {})
}

function closeComposition() {
  if (
    store.hasChanges &&
    !window.confirm('You have unsaved changes. Are you sure you want to leave?')
  ) {
    return
  }

  imageQuery.value = null
  store.reset()
  setParam(RouteNames.LightTable, 'composition_id')
}

onBeforeMount(() => {
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

  if (compositionId) openComposition(compositionId)
})
</script>
