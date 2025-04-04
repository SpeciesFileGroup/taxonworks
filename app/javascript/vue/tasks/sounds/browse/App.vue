<template>
  <div id="app">
    <div class="flex-separate middle">
      <VSpinner
        v-if="isLoading"
        full-screen
      />
      <h1>Browse sound</h1>
      <VAutocomplete
        v-if="store.sound"
        url="/sounds/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a sound..."
        @get-item="(item) => loadData(item.id)"
      />
    </div>
    <div class="app-container gap-medium">
      <HeaderBar
        :sound="store.sound"
        @select="loadData"
      />
      <template v-if="store.sound">
        <PanelSound :sound="store.sound" />
        <PanelConveyances :conveyances="store.conveyances" />
        <PanelAnnotations
          :object-id="store.sound.id"
          :object-type="store.sound.base_class"
        />
      </template>
    </div>
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { URLParamsToJSON } from '@/helpers'
import { RouteNames } from '@/routes/routes.js'
import { usePopstateListener } from '@/composables'
import useStore from './store/store.js'
import PanelSound from './components/Panel/PanelSound.vue'
import PanelConveyances from './components/Panel/PanelConveyances.vue'
import PanelAnnotations from './components/Panel/PanelAnnotations.vue'
import HeaderBar from './components/HeaderBar.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import setParam from '@/helpers/setParam'

defineOptions({
  name: 'BrowseSound'
})
const store = useStore()
const isLoading = ref(false)

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

onBeforeMount(loadDataFromIdParameter)
usePopstateListener(loadDataFromIdParameter)
</script>

<style scoped>
#app {
  margin: 0 auto;
  width: 1240px;
}

.app-container {
  display: grid;
  grid-column: 1fr 2fr 1fr;
}
</style>
