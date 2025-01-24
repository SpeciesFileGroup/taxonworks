<template>
  <div id="app">
    <div class="flex-separate middle">
      <h1>Browse sound</h1>
      <VAutocomplete
        v-if="store.sound"
        url="/sounds/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a sound..."
        @get-item="(item) => store.loadSound(item.id)"
      />
    </div>
    <div class="app-container gap-medium">
      <HeaderBar
        :sound="store.sound"
        @select="store.loadSound"
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
import useStore from './store/store.js'
import { onBeforeMount } from 'vue'
import PanelSound from './components/Panel/PanelSound.vue'
import PanelConveyances from './components/Panel/PanelConveyances.vue'
import PanelAnnotations from './components/Panel/PanelAnnotations.vue'
import { URLParamsToJSON } from '@/helpers'
import HeaderBar from './components/HeaderBar.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'

defineOptions({
  name: 'BrowseSound'
})
const store = useStore()

onBeforeMount(() => {
  const params = URLParamsToJSON(window.location.href)
  const soundId = params.sound_id

  if (soundId) {
    store.loadSound(soundId)
    store.loadConveyances(soundId)
  }
})
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
