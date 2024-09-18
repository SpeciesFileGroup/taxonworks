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
      <PanelOtu />
      <PanelGeographicArea />
      <PanelConfidence />
    </div>

    <TableComponent
      class="full_width"
      @on-source-otu="setSourceOtu"
      @on-source-geo="setSourceGeo"
      @on-otu-geo="setGeoOtu"
    />
  </div>
</template>

<script setup>
import PanelOtu from './components/Panel/PanelOtu.vue'
import PanelGeographicArea from './components/Panel/PanelGeographicArea.vue'
import PanelCitation from './components/Panel/PanelCitation.vue'
import PanelConfidence from './components/Panel/PanelConfidence.vue'
import TableComponent from './components/table'
import VSpinner from '@/components/ui/VSpinner'
import NavBar from '@/components/layout/NavBar'
import platformKey from '@/helpers/getPlatformKey'

import useHotkey from 'vue3-hotkey'
import { Source } from '@/routes/endpoints'
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

function setSourceOtu(item) {
  store.reset()
  setCitation(item.citations[0])
  store.otu = item.otu
}

function setSourceGeo(item) {
  store.reset()
  setCitation(item.citations[0])
  store.geographicArea = item.geographic_area
  store.isAbsent = item.is_absent
}

function setGeoOtu(item) {
  store.reset()
  store.autosave = false
  store.assertedDistribution.id = item.id
  store.geographicArea = item.geographic_area
  store.otu = item.otu
  store.isAbsent = item.is_absent
}

function setCitation(citation) {
  Source.find(citation.source_id).then(({ body }) => {
    store.citation = {
      id: undefined,
      source: body,
      source_id: citation.source_id,
      is_original: citation.is_original,
      pages: citation.pages
    }
  })
}
</script>

<style scoped>
.grid-panels {
  display: grid;
  grid-template-columns: 1fr 1fr 0.75fr;
}
</style>
