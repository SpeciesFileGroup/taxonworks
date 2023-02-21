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
    v-if="showViewContext"
    :position="currentEvent"
    @focusout="() => (showViewContext = false)"
  >
    <p>Add node</p>
    <div class="graph-context-menu-buttons">
      <VBtn
        color="primary"
        @click="() => (isModalNodeVisible = true)"
      >
        OTU
      </VBtn>
      <VBtn color="primary"> Collection Object </VBtn>
    </div>
  </GraphContextMenu>

  <GraphContextMenu
    v-if="showNodeMenu"
    :position="currentEvent"
    @focusout="() => (showNodeMenu = false)"
  >
    <div class="flex-separate middle">
      {{ store.getNodes[menuTargetNode]?.name }}
      <VBtn
        circle
        color="primary"
        @click="
          () => {
            store.removeNode(menuTargetNode)
            showNodeMenu = false
          }
        "
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
    </div>
  </GraphContextMenu>

  <GraphContextMenu
    v-if="showEdgeMenu"
    :position="currentEvent"
    @focusout="() => (showEdgeMenu = false)"
  >
    <div
      v-for="edge in menuTargetEdges"
      :key="edge"
    >
      {{ store.edges[edge]?.label }}
      <VBtn
        circle
        color="primary"
        @click="
          () => {
            store.removeEdge(edge)
            showEdgeMenu = false
          }
        "
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
    </div>
  </GraphContextMenu>
  <ModalNode
    v-if="isModalNodeVisible"
    @close="() => (isModalNodeVisible = false)"
  />
  <ModalEdge
    v-if="isModalEdgeVisible"
    @close="() => (isModalEdgeVisible = false)"
  />
</template>

<script setup>
import { ref } from 'vue'
import { useGraphStore } from '../store/useGraphStore.js'
import ModalNode from './ModalNode.vue'
import ModalEdge from './ModalEdge.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import GraphContextMenu from './ContextMenu.vue'
import { configs } from '../constants/networkConfig'

const store = useGraphStore()
const isModalEdgeVisible = ref(false)
const isModalNodeVisible = ref(false)
const currentEvent = ref()

function showContextMenu(element, event) {
  element.style.left = event.x + 'px'
  element.style.top = event.y + 'px'
  element.style.visibility = 'visible'
  const handler = (event) => {
    if (!event.target || !element.contains(event.target)) {
      element.style.visibility = 'hidden'
      document.removeEventListener('pointerdown', handler, { capture: true })
    }
  }
  document.addEventListener('pointerdown', handler, {
    passive: true,
    capture: true
  })
}

const showViewContext = ref()
function showViewContextMenu(params) {
  const { event } = params

  event.stopPropagation()
  event.preventDefault()

  if (!graph.value) return

  const point = { x: event.offsetX, y: event.offsetY }

  store.currentSVGCursorPosition =
    graph.value.translateFromDomToSvgCoordinates(point)

  currentEvent.value = event
  showViewContext.value = true
}

const showNodeMenu = ref(false)
const menuTargetNode = ref('')

function showNodeContextMenu(params) {
  const { node, event } = params

  handleEvent(event)
  menuTargetNode.value = node
  showNodeMenu.value = true
}

const showEdgeMenu = ref(false)
const menuTargetEdges = ref([])
function showEdgeContextMenu(params) {
  const { event } = params

  handleEvent(event)
  menuTargetEdges.value = params.summarized ? params.edges : [params.edge]
  showEdgeMenu.value = true
}

function handleEvent(event) {
  event.stopPropagation()
  event.preventDefault()
  currentEvent.value = event
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
  height: calc(100vh - 180px);
}
</style>
