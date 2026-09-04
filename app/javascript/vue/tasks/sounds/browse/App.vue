<template>
  <div class="container-xl mx-auto">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <HeaderBar
      ref="headerBarRef"
      :sound="store.sound"
      @select="loadData"
    />
    <div
      v-if="store.sound"
      class="browse-layout gap-medium"
    >
      <div class="flex-col gap-medium">
        <PanelSound
          ref="panelSoundRef"
          :sound="store.sound"
          :conveyances="store.conveyances"
        />
        <PanelConveyances
          :conveyances="store.conveyances"
          @play="({ start, end }) => panelSoundRef?.playRegion(start, end)"
        />
      </div>
      <div class="flex-col gap-medium browse-sidebar">
        <PanelMetadata :sound="store.sound" />
        <PanelAnnotations
          :object-id="store.sound.id"
          :object-type="store.sound.base_class"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { onBeforeMount, ref, useTemplateRef } from 'vue'
import { getPlatformKey, URLParamsToJSON } from '@/helpers'
import { RouteNames } from '@/routes/routes.js'
import { useHotkey, usePopstateListener } from '@/composables'
import useStore from './store/store.js'
import PanelSound from './components/Panel/PanelSound.vue'
import PanelConveyances from './components/Panel/PanelConveyances.vue'
import PanelAnnotations from './components/Panel/PanelAnnotations.vue'
import PanelMetadata from './components/Panel/PanelMetadata.vue'
import HeaderBar from './components/HeaderBar.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import setParam from '@/helpers/setParam'

defineOptions({
  name: 'BrowseSound'
})

const store = useStore()
const isLoading = ref(false)
const headerBarRef = useTemplateRef('headerBarRef')
const panelSoundRef = useTemplateRef('panelSoundRef')

function loadData(soundId) {
  setParam(RouteNames.BrowseSound, 'sound_id', soundId)

  store.$reset()
  isLoading.value = true

  Promise.all([store.loadSound(soundId), store.loadConveyances(soundId)])
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function loadDataFromIdParameter() {
  const params = URLParamsToJSON(window.location.href)
  const soundId = params.sound_id

  if (soundId) {
    loadData(soundId)
  }
}

useHotkey([
  {
    keys: [getPlatformKey(), 'f'],
    preventDefault: true,
    handler() {
      headerBarRef.value?.setFocus()
    }
  }
])

TW.workbench.keyboard.createLegend(
  `${getPlatformKey()}+f`,
  'Search a sound',
  'Browse sound'
)

onBeforeMount(loadDataFromIdParameter)
usePopstateListener(loadDataFromIdParameter)
</script>

<style scoped>
.browse-layout {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(0, 1fr);
  align-items: start;
}

.browse-sidebar {
  position: sticky;
  top: var(--spacing-md);
}

@media (max-width: 1100px) {
  .browse-layout {
    grid-template-columns: minmax(0, 1fr);
  }

  .browse-sidebar {
    position: static;
  }
}
</style>
