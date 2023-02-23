<template>
  <VNetworkGraph
    ref="graph"
    class="graph panel"
    :configs="configs"
    :edges="store.getEdges"
    :event-handlers="eventHandlers"
    v-model:selected-nodes="store.selectedNodes"
    v-model:nodes="store.nodes"
    v-model:layouts="store.layouts"
  >
    <template #edge-label="{ edge, ...slotProps }">
      <VEdgeLabel
        :text="edge.label"
        align="center"
        vertical-align="below"
        v-bind="slotProps"
      />
    </template>
  </VNetworkGraph>

  <GraphContextMenu
    v-if="showViewMenu"
    :position="store.currentEvent"
    @focusout="() => (showViewMenu = false)"
  >
    <ContextMenuView @focusout="() => (showViewMenu = false)" />
  </GraphContextMenu>

  <GraphContextMenu
    v-if="showNodeMenu"
    :position="store.currentEvent"
    @focusout="() => (showNodeMenu = false)"
  >
    <ContextMenuNode @focusout="() => (showNodeMenu = false)" />
  </GraphContextMenu>

  <GraphContextMenu
    v-if="showEdgeMenu"
    :position="store.currentEvent"
    @focusout="() => (showEdgeMenu = false)"
  >
    <ContextMenuEdge @focusout="() => (showEdgeMenu = false)" />
  </GraphContextMenu>
</template>

<script setup>
import { ref } from 'vue'
import { useGraphStore } from '../store/useGraphStore.js'
import { configs } from '../constants/networkConfig'
import dagre from 'dagre'
import GraphContextMenu from './ContextMenu/ContextMenu.vue'
import ContextMenuView from './ContextMenu/ContextMenuView.vue'
import ContextMenuNode from './ContextMenu/ContextMenuNode.vue'
import ContextMenuEdge from './ContextMenu/ContextMenuEdge.vue'

const store = useGraphStore()

const showViewMenu = ref()
function showViewContextMenu(params) {
  const { event } = params

  handleEvent(event)

  if (!graph.value) return

  const point = { x: event.offsetX, y: event.offsetY }

  store.currentSVGCursorPosition =
    graph.value.translateFromDomToSvgCoordinates(point)

  showViewMenu.value = true
}

const showNodeMenu = ref()

function showNodeContextMenu(params) {
  const { node, event } = params

  handleEvent(event)
  store.currentNode = node
  showNodeMenu.value = true
}

const showEdgeMenu = ref(false)
function showEdgeContextMenu(params) {
  const { event } = params

  handleEvent(event)
  store.currentEdge = params.summarized ? params.edges : [params.edge]
  showEdgeMenu.value = true
}

function handleEvent(event) {
  event.stopPropagation()
  event.preventDefault()
  store.currentEvent = event
}

const graph = ref()

const eventHandlers = {
  'view:contextmenu': showViewContextMenu,
  'node:contextmenu': showNodeContextMenu,
  'edge:contextmenu': showEdgeContextMenu
}

const nodeSize = 40

store.loadGraph(4).then((_) => {
  updateLayout('LR')
})

function layout(direction) {
  if (
    Object.keys(store.nodes).length <= 1 ||
    Object.keys(store.edges).length === 0
  ) {
    return
  }

  // convert graph
  // ref: https://github.com/dagrejs/dagre/wiki
  const g = new dagre.graphlib.Graph()
  // Set an object for the graph label
  g.setGraph({
    rankdir: direction,
    nodesep: nodeSize * 2,
    edgesep: nodeSize,
    ranksep: nodeSize * 2
  })
  // Default to assigning a new object as a label for each new edge.
  g.setDefaultEdgeLabel(() => ({}))

  // Add nodes to the graph. The first argument is the node id. The second is
  // metadata about the node. In this case we're going to add labels to each of
  // our nodes.
  Object.entries(store.nodes).forEach(([nodeId, node]) => {
    g.setNode(nodeId, { label: node.name, width: nodeSize, height: nodeSize })
  })

  // Add edges to the graph.
  Object.values(store.edges).forEach((edge) => {
    g.setEdge(edge.source, edge.target)
  })

  dagre.layout(g)

  const box = {}
  g.nodes().forEach((nodeId) => {
    // update node position
    const x = g.node(nodeId).x
    const y = g.node(nodeId).y
    store.layouts.nodes[nodeId] = { x, y }

    // calculate bounding box size
    box.top = box.top ? Math.min(box.top, y) : y
    box.bottom = box.bottom ? Math.max(box.bottom, y) : y
    box.left = box.left ? Math.min(box.left, x) : x
    box.right = box.right ? Math.max(box.right, x) : x
  })

  const graphMargin = nodeSize * 2
  const viewBox = {
    top: (box.top ?? 0) - graphMargin,
    bottom: (box.bottom ?? 0) + graphMargin,
    left: (box.left ?? 0) - graphMargin,
    right: (box.right ?? 0) + graphMargin
  }
  graph.value?.setViewBox(viewBox)
}

function updateLayout(direction) {
  graph.value?.transitionWhile(() => {
    layout(direction)
  })
}
</script>

<style lang="scss" scoped>
.graph {
  width: calc(100vw - 2em);
  height: calc(100vh - 250px);
}
</style>
