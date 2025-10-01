<template>
  <div
    class="panel relative"
    v-help.canvas
  >
    <VSpinner
      v-if="isLoading"
      legend="Loading anatomical parts graph..."
    />
    <div
      v-if="!Object.keys(nodes).length"
      id="background"
    >
      <h2 class="subtle">Search for an anatomical part, the origin of an anatomical part, or the endpoint of an anatomical part</h2>
    </div>
    <VNetworkGraph
      ref="networkGraph"
      class="graph"
      :configs="configs"
      :edges="edges"
      :nodes="nodes"
      :event-handlers="eventHandlers"
      v-model:selected-nodes="selectedNodes"
      v-model:selected-edges="selectedEdges"
      v-model:layouts="layouts"
    />

    <ContextMenu ref="nodeContextMenu">
      <ContextMenuNode
        :node="nodes[currentNodeId]"
        :node-id="currentNodeId"
      />
    </ContextMenu>

    <ContextMenu ref="edgeContextMenu">
      <ContextMenuEdge
        :edges="edges"
        :selected-edges="selectedEdges"
      />
    </ContextMenu>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { configs } from '../constants/networkConfig.js'
import { useGraph } from '../composition/useGraph.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import ContextMenu from '@/components/graph/ContextMenu.vue'
import ContextMenuEdge from './ContextMenu/ContextMenuEdge.vue'
import ContextMenuNode from './ContextMenu/ContextMenuNode.vue'

const {
  currentGraph,
  currentNodes,
  edges,
  isLoading,
  layouts,
  loadGraph,
  nodes,
  resetStore,
  selectedEdges,
  selectedNodes,
} = useGraph()

const networkGraph = ref()
const edgeContextMenu = ref()
const nodeContextMenu = ref()
const currentNodeId = ref()
const currentEvent = ref()

const eventHandlers = {
  'node:contextmenu': showNodeContextMenu,
  'edge:contextmenu': showEdgeContextMenu
}

function createGraph(idsHash) {
  loadGraph(idsHash).then((_) => {
    networkGraph.value.fitToContents()
  })
}

function showNodeContextMenu({ node, event }) {
  handleEvent(event)
  currentNodeId.value = node
  nodeContextMenu.value.openContextMenu(currentEvent.value)
}

function showEdgeContextMenu({ event, edge }) {
  handleEvent(event)
  if (!selectedEdges.value.includes(edge)) {
    selectedEdges.value.push(edge)
  }
  edgeContextMenu.value.openContextMenu(currentEvent.value)
}

function handleEvent(event) {
  event.stopPropagation()
  event.preventDefault()
  currentEvent.value = event
}


async function downloadAsSvg() {
  if (!networkGraph.value) return
  const text = await networkGraph.value.exportAsSvgText()
  const url = URL.createObjectURL(new Blob([text], { type: 'octet/stream' }))
  const a = document.createElement('a')
  a.href = url
  a.download = 'anatomical-part-network-graph.svg'
  a.click()
  window.URL.revokeObjectURL(url)
}

defineExpose({
  currentNodes,
  resetStore,
  createGraph,
  downloadAsSvg,
})
</script>

<style lang="scss" scoped>
#background {
  display: flex;
  justify-content: center;
  align-items: center;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
  overflow: hidden;
  width: 100%;
  height: 100%;
}

.graph {
  width: calc(100vw - 450px);
  height: calc(100vh - 250px);
}
</style>
