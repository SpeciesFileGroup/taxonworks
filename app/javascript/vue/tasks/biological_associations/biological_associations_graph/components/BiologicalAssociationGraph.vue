<template>
  <VNetworkGraph
    ref="graph"
    class="graph panel"
    :configs="configs"
    :edges="edges"
    :nodes="nodes"
    :event-handlers="eventHandlers"
    v-model:selected-nodes="selectedNodes"
    v-model:layouts="layouts"
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

  <ContextMenu ref="viewContextMenu">
    <ContextMenuView @add:node="openNodeModal" />
  </ContextMenu>

  <ContextMenu ref="nodeContextMenu">
    <ContextMenuNode
      :node="nodes[currentNodeId]"
      :node-id="currentNodeId"
      :is-saved="isCurrentNodeSaved"
      :create-button="selectedNodes.length === 2"
      @remove:node="handleRemoveNode"
      @add:edge="openEdgeModal"
    />
  </ContextMenu>

  <ContextMenu ref="edgeContextMenu">
    <ContextMenuEdge
      :edge="edges[currentEdgeId]"
      :edge-id="currentEdgeId"
      @reverse:edge="(edgeId) => reverseRelation(edgeId)"
      @remove:edge="handleRemoveEdge"
    />
  </ContextMenu>

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

  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { computed, ref } from 'vue'
import { configs } from '../constants/networkConfig'
import { graphLayout } from '../utils/graphLayout.js'
import { useGraph } from '../composition/useGraph.js'
import { makeNodeId } from '../utils/makeNodeId.js'
import ConfirmationModal from 'components/ConfirmationModal.vue'
import ModalObject from './ModalObject.vue'
import ModalEdge from './ModalEdge.vue'
import VSpinner from 'components/spinner.vue'
import ContextMenu from './ContextMenu/ContextMenu.vue'
import ContextMenuEdge from './ContextMenu/ContextMenuEdge.vue'
import ContextMenuView from './ContextMenu/ContextMenuView.vue'
import ContextMenuNode from './ContextMenu/ContextMenuNode.vue'

const showModalNode = ref(false)
const showModalEdge = ref(false)
const nodeType = ref()
const {
  loadGraph,
  nodes,
  edges,
  layouts,
  addObject,
  setNodePosition,
  selectedNodes,
  isSaving,
  removeNode,
  removeEdge,
  getBiologicalRelationshipsByNodeId,
  createBiologicalRelationship,
  reverseRelation,
  saveBiologicalAssociations
} = useGraph()

const graph = ref()
const edgeContextMenu = ref()
const nodeContextMenu = ref()
const viewContextMenu = ref()

const currentNodeId = ref()
const currentEdgeId = ref()
const currentEvent = ref()
const currentPosition = ref()

const isCurrentNodeSaved = computed(() =>
  getBiologicalRelationshipsByNodeId(currentNodeId.value).some((ba) => ba.id)
)

function showViewContextMenu({ event }) {
  const point = { x: event.offsetX, y: event.offsetY }

  handleEvent(event)
  currentPosition.value = graph.value.translateFromDomToSvgCoordinates(point)
  viewContextMenu.value.openContextMenu(currentEvent.value)
}

function showNodeContextMenu({ node, event }) {
  handleEvent(event)
  currentNodeId.value = node
  nodeContextMenu.value.openContextMenu(currentEvent.value)
}

function showEdgeContextMenu({ event, edge }) {
  handleEvent(event)
  currentEdgeId.value = edge
  edgeContextMenu.value.openContextMenu(currentEvent.value)
}

function handleEvent(event) {
  event.stopPropagation()
  event.preventDefault()
  currentEvent.value = event
}

const eventHandlers = {
  'view:contextmenu': showViewContextMenu,
  'node:contextmenu': showNodeContextMenu,
  'edge:contextmenu': showEdgeContextMenu
}

const confirmationModalRef = ref()

async function handleRemoveNode(node) {
  const ok =
    !isCurrentNodeSaved.value ||
    (await confirmationModalRef.value.show({
      title: 'Destroy biological association',
      message:
        'This will delete biological associations connected to this node. Are you sure you want to proceed?',
      okButton: 'Destroy',
      cancelButton: 'Cancel',
      typeButton: 'delete'
    }))

  if (ok) {
    removeNode(node)
  }
}

async function handleRemoveEdge(edgeId) {
  const ok =
    !edges.value[edgeId].id ||
    (await confirmationModalRef.value.show({
      title: 'Destroy biological association',
      message:
        'This will delete the biological association. Are you sure you want to proceed?',
      okButton: 'Destroy',
      cancelButton: 'Cancel',
      typeButton: 'delete'
    }))

  if (ok) {
    removeEdge(edgeId)
  }
}

function updateLayout(direction) {
  graph.value?.transitionWhile(() => {
    const data = graphLayout({
      direction,
      nodes: nodes.value,
      edges: edges.value,
      nodeSize: 40
    })

    layouts.value = data.layouts
    graph.value.setViewBox(data.viewBox)
  })
}

function openNodeModal({ type }) {
  nodeType.value = type
  showModalNode.value = true
}

function openEdgeModal() {
  showModalEdge.value = true
}

function setGraph(graphId) {
  loadGraph(graphId).then((_) => {
    updateLayout('LR')
  })
}

defineExpose({
  setGraph,
  saveBiologicalAssociations,
  updateLayout
})
</script>

<style lang="scss" scoped>
.graph {
  width: calc(100vw - 2em);
  height: calc(100vh - 250px);
}
</style>
