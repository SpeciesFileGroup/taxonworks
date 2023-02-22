<template>
  <VNetworkGraph
    ref="graph"
    class="graph"
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
</script>

<style lang="scss" scoped>
.graph {
  width: calc(100vw - 2em);
  height: calc(100vh - 250px);
}
</style>
