<template>
  <h1>Monograph facilitator</h1>
  <VSpinner
    v-if="store.isLoading"
    full-screen
  />
  <div class="app-container horizontal-left-content gap-medium align-start">
    <div class="flex-col gap-medium left-column">
      <PanelGroup />
      <PanelObject />
    </div>
    <PanelMap />
  </div>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import PanelObject from './Panel/PanelObject/PanelObject.vue'
import PanelMap from './Panel/PanelMap.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

import useStore from './store/store.js'
import PanelGroup from './Panel/PanelGroup.vue'

defineOptions({
  name: 'MonographFacilitator'
})

const store = useStore()

onBeforeMount(() => {
  store.load()
})
</script>

<style scoped>
.app-container {
  max-height: calc(100vh - 12rem);
  height: calc(100vh - 12rem);
}

.left-column {
  max-height: 100%;
  overflow-y: auto;
  overflow-x: hidden;
  min-width: 400px;
  width: 400px;
}
</style>
