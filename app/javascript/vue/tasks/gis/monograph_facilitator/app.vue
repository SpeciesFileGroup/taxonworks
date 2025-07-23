<template>
  <h1>Monograph facilitator</h1>
  <VSpinner
    v-if="store.isLoading"
    full-screen
  />
  <div class="app-container horizontal-left-content gap-medium align-start">
    <PanelObject />
    <PanelMap />
  </div>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import PanelObject from './Panel/PanelObject/PanelObject.vue'
import PanelMap from './Panel/PanelMap.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

import useStore from './store/store.js'

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
</style>
