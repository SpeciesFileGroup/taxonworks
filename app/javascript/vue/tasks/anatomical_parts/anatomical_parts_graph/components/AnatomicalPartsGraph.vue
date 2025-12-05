<template>
  <div
    class="panel relative"
    :class="containerClasses"
    v-help.canvas
  >
    <VSpinner
      v-if="isLoading"
      legend="Loading anatomical parts graph..."
      full-screen
    />
    <div
      v-if="!Object.keys(nodes).length"
      id="background"
    >
      <h2 class="subtle">To create a new anatomical part, first load the origin of the part. Right click on nodes for a context menu.</h2>
    </div>
    <VNetworkGraph
      ref="networkGraph"
      :style="{ width: graphWidth, height: graphHeight }"
      :configs="configs"
      :edges="edges"
      :nodes="nodes"
      :layouts="layouts"
      :event-handlers="eventHandlers"
      v-model:selected-nodes="selectedNodes"
      v-model:selected-edges="selectedEdges"
      v-model:layouts="layouts"
    />

    <ContextMenu ref="nodeContextMenu">
      <ContextMenuNode
        :node="nodes[currentNodeId]"
        :node-id="currentNodeId"
        :in-edit-mode="showNodeQuickForms"
        :context="nodeContextMenu"
        @update-graph="() => emit('updateGraph')"
        @close="() => (nodeContextMenu.closeContextMenu())"
      />
    </ContextMenu>

    <ContextMenu ref="edgeContextMenu">
      <ContextMenuEdge
        :edges="edges"
        :selected-edge-ids="selectedEdges"
      />
    </ContextMenu>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { configs } from '../constants/networkConfig.js'
import { graphLayout } from '../utils/graphLayout.js'
import { useGraph } from '../composition/useGraph.js'
import { vHelp } from '@/directives/help.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import ContextMenu from '@/components/graph/ContextMenu.vue'
import ContextMenuEdge from './ContextMenu/ContextMenuEdge.vue'
import ContextMenuNode from './ContextMenu/ContextMenuNode.vue'
import { VNetworkGraph } from 'v-network-graph'

const props = defineProps({
  showNodeQuickForms: {
    type: Boolean,
    default: true
  },

  graphWidth: {
    type: String,
    default: null
  },

  graphHeight: {
    type: String,
    default: null
  },

  containerClasses: {
    type: Object,
    default: () => ({})
  }
})

const {
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

const emit = defineEmits(['updateGraph'])

const eventHandlers = {
  'node:contextmenu': showNodeContextMenu,
  'edge:contextmenu': showEdgeContextMenu
}

function createGraph(idsHash) {
  loadGraph(idsHash).then((_) => {
    //networkGraph.value.fitToContents()
    updateLayout('TB')
  })
}

function updateLayout(direction) {
  networkGraph.value?.transitionWhile(() => {
    const data = graphLayout({
      nodes: nodes.value,
      edges: edges.value,
      nodeSize: 40
    })

    if (!data) return

    layouts.value = data.layouts
    networkGraph.value.setViewBox(data.viewBox)
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

</style>
