<template>
  <div id="vue-task-asserted-distribution-new">
    <VSpinner
      v-if="store.isLoading"
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
      legend="Loading..."
    />
    <h1>Task - New asserted distribution</h1>
    <NavBar class="margin-medium-bottom">
      <div class="flex-separate middle">
        <div>
          <span
            v-if="currentAssertedDistribution"
            v-html="currentAssertedDistribution.object_tag"
          />
          <span v-else>New record</span>
        </div>
        <div class="horizontal-center-content middle gap-small">
          <label class="middle">
            <input
              v-model="store.autosave"
              type="checkbox"
            />
            Autosave
          </label>
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
        </div>
      </div>
    </NavBar>

    <div class="grid-panels gap-medium margin-medium-bottom">
      <PanelCitation />
      <PanelObject />
      <PanelGeo />
      <PanelConfidence />
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
import VSpinner from '@/components/ui/VSpinner'
import NavBar from '@/components/layout/NavBar'
import platformKey from '@/helpers/getPlatformKey'

import { useHotkey } from '@/composables'
import { computed, ref, onBeforeMount } from 'vue'
import { useStore } from './store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'

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

const currentAssertedDistribution = computed(() =>
  store.assertedDistributions.find(
    (item) => item.id === store.assertedDistribution.id
  )
)

onBeforeMount(() => {
  store.loadRecentAssertedDistributions()

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
