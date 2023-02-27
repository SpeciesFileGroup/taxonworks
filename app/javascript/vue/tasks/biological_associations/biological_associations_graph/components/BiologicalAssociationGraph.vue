<template>
  <section class="graph-section">
    <NetworkCanvas
      :nodes="nodes"
      :edges="edges"
      v-model:layouts="layouts"
      v-model:selectedNodes="selectedNodes"
      @add:node="openNodeModal"
      @add:edge="openEdgeModal"
      @reverse:edge="reverseRelation"
      @view:position="($event) => (currentPosition = $event)"
      ref="networkRef"
    />
  </section>

  <ModalObject
    v-if="showModalNode"
    :type="nodeType"
    @add-object="
      ($event) => {
        addObject($event)
        setNodePosition(makeNodeId($event), currentPosition)
        showModalNode = false
      }
    "
    @close="() => (showModalNode = false)"
  />
  <ModalEdge
    v-if="showModalEdge"
    @add-relationship="
      ($event) => {
        createBiologicalRelationship({
          subjectNodeId: selectedNodes[0],
          objectNodeId: selectedNodes[1],
          relationship: $event
        })
        showModalEdge = false
      }
    "
    @close="() => (showModalEdge = false)"
  />
  <VSpinner
    v-if="isSaving"
    full-screen
    legend="Saving biological associations..."
  />
</template>

<script setup>
import NetworkCanvas from './NetworkCanvas.vue'
import ModalObject from './ModalObject.vue'
import ModalEdge from './ModalEdge.vue'
import VSpinner from 'components/spinner.vue'
import { ref } from 'vue'
import { useGraph } from '../composition/useGraph.js'
import { makeNodeId } from '../utils/makeNodeId.js'

const networkRef = ref()
const showModalNode = ref(false)
const showModalEdge = ref(false)
const nodeType = ref()
const currentPosition = ref()
const {
  loadGraph,
  nodes,
  edges,
  layouts,
  addObject,
  setNodePosition,
  selectedNodes,
  isSaving,
  createBiologicalRelationship,
  reverseRelation,
  saveBiologicalAssociations
} = useGraph()

function openNodeModal({ type }) {
  nodeType.value = type
  showModalNode.value = true
}

function openEdgeModal() {
  showModalEdge.value = true
}

function setGraph(graphId) {
  loadGraph(graphId).then((_) => {
    networkRef.value.updateLayout('LR')
  })
}

defineExpose({
  setGraph,
  saveBiologicalAssociations
})
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>
