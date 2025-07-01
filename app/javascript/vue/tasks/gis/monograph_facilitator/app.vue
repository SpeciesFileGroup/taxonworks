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
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import PanelObject from './Panel/PanelObject/PanelObject.vue'
import PanelMap from './Panel/PanelMap.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

import useStore from './store/store.js'

defineOptions({
  name: 'MonographFacilitator'
})

const { queryValue, queryParam } = useQueryParam()
const store = useStore()

onBeforeMount(() => {
  store.load(queryValue.value)
})
</script>

<style scoped>
.app-container {
  max-height: calc(100vh - 16rem);
  height: calc(100vh - 16rem);
}
</style>
