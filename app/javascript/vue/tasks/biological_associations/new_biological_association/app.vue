<template>
  <div>
    <VSpinner
      v-if="store.isLoading"
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
      legend="Loading..."
    />
    <h1>New biological association</h1>
    <NavBar class="margin-medium-bottom">
      <div class="flex-separate middle">
        <div>
          <span
            v-if="currentBiologicalAssociation"
            v-html="currentBiologicalAssociation.object_tag"
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
            @click="store.saveBiologicalAssociation"
          >
            {{ store.biologicalAssociation.id ? 'Update' : 'Create' }}
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
      <PanelObject
        title="Subject"
        v-model="store.subject"
        v-model:lock="store.lock.subject"
      />
      <PanelRelationship
        v-model="store.relationship"
        v-model:lock="store.lock.relationship"
      />
      <PanelObject
        title="Related"
        v-model="store.object"
        v-model:lock="store.lock.object"
      />
      <PanelCitation />
    </div>
    <TableResults :list="store.biologicalAssociations" />
  </div>
</template>

<script setup>
import { useHotkey } from '@/composables'
import { computed, ref, onBeforeMount } from 'vue'
import { useStore } from './store/store.js'
import VSpinner from '@/components/ui/VSpinner'
import NavBar from '@/components/layout/NavBar'
import platformKey from '@/helpers/getPlatformKey'
import VBtn from '@/components/ui/VBtn/index.vue'
import PanelRelationship from './components/Panel/PanelRelationship.vue'
import PanelObject from './components/Panel/PanelObject.vue'
import PanelCitation from './components/Panel/PanelCitation.vue'
import TableResults from './components/TableResults.vue'

defineOptions({
  name: 'NewBiologicalAssociation'
})

const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      store.saveBiologicalAssociation()
    }
  }
])

useHotkey(shortcuts.value)

const store = useStore()

const currentBiologicalAssociation = computed(() =>
  store.biologicalAssociations.find(
    (item) => item.id === store.biologicalAssociation.id
  )
)

onBeforeMount(() => {
  store.loadRecentBiologicalAssociations()

  TW.workbench.keyboard.createLegend(
    `${platformKey()}+s`,
    'Save and create new biological association',
    'New biological association'
  )
})
</script>

<style scoped>
.grid-panels {
  display: grid;
  grid-template-columns: 1fr 1fr 0.75fr;
}
</style>
