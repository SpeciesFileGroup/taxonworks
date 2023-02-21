<template>
  <FacetContainer class="relationship-panel">
    <h3>Select a biological relationship</h3>
    <SmartSelector
      model="biological_relationships"
      @selected="addRelationship"
    />
  </FacetContainer>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector'
import { useGraphStore } from '../store/useGraphStore'
import FacetContainer from 'components/Filter/Facets/FacetContainer'

const emit = defineEmits('close')
const store = useGraphStore()

function addRelationship(relationship) {
  const [source, target] = store.selectedNodes

  store.createEdge({
    source,
    target,
    relationship
  })
  emit('close')
}
</script>

<style scoped>
.relationship-panel {
  position: absolute;
  width: 400px;
  left: 0px;
  top: 0px;
}
</style>
