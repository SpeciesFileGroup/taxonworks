<template>
  <VModal @close="() => (isModalVisible = false)">
    <template #header>
      <h3>Select a biological relationship</h3>
    </template>
    <template #body>
      <SmartSelector
        model="biological_relationships"
        @selected="addRelation"
      />
    </template>
  </VModal>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import VModal from 'components/ui/Modal.vue'
import { useGraphStore } from '../store/useGraphStore'

const store = useGraphStore()

function addRelation(relationship) {
  const [source, target] = store.selectedNodes

  store.createEdge({
    source,
    target,
    relationship
  })

  store.modal.edge = false
}
</script>
