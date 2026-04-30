<template>
  <div class="collection-layout-task">
    <h1>Collection layout</h1>

    <div class="top-panel panel content">
      <BuildingSelector v-model="building" />
      <ScaffoldForm
        :building="building"
        @scaffolded="onScaffolded"
      />
    </div>

    <div class="bottom-panel gap-medium">
      <ContainerTreeList
        ref="treeListRef"
        :building-id="building?.id ?? null"
        @navigate="onNavigate"
      />

      <div class="grid-panel panel content">
        <BuildingGrid
          ref="buildingGridRef"
          :building-id="building?.id ?? null"
          @add-container="onGridAddContainer"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import BuildingSelector from './components/BuildingSelector.vue'
import ScaffoldForm from './components/ScaffoldForm.vue'
import ContainerTreeList from './components/ContainerTreeList.vue'
import BuildingGrid from './components/BuildingGrid.vue'

defineOptions({ name: 'CollectionLayout' })

const building        = ref(null)
const buildingGridRef = ref(null)
const treeListRef     = ref(null)

async function onScaffolded() {
  await Promise.all([
    treeListRef.value?.refresh(),
    buildingGridRef.value?.reload()
  ])
}

function onNavigate(path) {
  buildingGridRef.value?.navigateTo(path)
}

function onGridAddContainer({ container, col, row }) {
  // TODO: persist container at (col, row) within the building once coordinate
  // storage is implemented on ContainerItem or Container.
  console.log('Add container', container.id, 'at', col, row)
}
</script>

<style scoped>
.collection-layout-task {
  padding: 1em;
}

.top-panel {
  margin-bottom: 1em;
}

.bottom-panel {
  display: flex;
  gap: 1em;
}

.grid-panel {
  flex: 1 1 0;
  min-width: 0;
}
</style>
