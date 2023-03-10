<template>
  <slot
    name="header"
    :selected-nodes="selectedNodes"
    :is-graph-unsaved="isGraphUnsaved"
    :edges="edges"
    :current-graph="currentGraph"
  />
  <VNetworkGraph
    ref="graph"
    class="graph panel"
    :configs="configs"
    :edges="edges"
    :nodes="nodes"
    :event-handlers="eventHandlers"
    v-model:selected-nodes="selectedNodes"
    v-model:selected-edges="selectedEdges"
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
    <ContextMenuView
      @add:node="openNodeModal"
      @cite:graph="
        () => openCitationModal({ type: BIOLOGICAL_ASSOCIATIONS_GRAPH })
      "
    />
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
      :edges="edges"
      :selected-edge-ids="selectedEdges"
      @cite:edge="() => openCitationModal({ type: BIOLOGICAL_ASSOCIATION })"
      @reverse:edge="(edgeId) => reverseRelation(edgeId)"
      @remove:edge="handleRemoveEdge"
    />
  </ContextMenu>

  <ModalObject
    v-if="showModalNode"
    :type="nodeType"
    @add:object="
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
    @add:relationship="
      ($event) => {
        addBiologicalRelationship({
          subjectNodeId: selectedNodes[0],
          objectNodeId: selectedNodes[1],
          relationship: $event
        })
        showModalEdge = false
      }
    "
    @close="() => (showModalEdge = false)"
  />
  <ModalCitation
    v-if="showModalCitation"
    @add:citation="handleCitationModal"
    @close="() => (showModalCitation = false)"
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
import { useGraph } from '../composition/useGraph.js'
import { makeNodeId } from '../utils/makeNodeId.js'
import ConfirmationModal from 'components/ConfirmationModal.vue'
import ModalCitation from './ModalCitation.vue'
import ModalObject from './ModalObject.vue'
import ModalEdge from './ModalEdge.vue'
import VSpinner from 'components/spinner.vue'
import ContextMenu from './ContextMenu/ContextMenu.vue'
import ContextMenuEdge from './ContextMenu/ContextMenuEdge.vue'
import ContextMenuView from './ContextMenu/ContextMenuView.vue'
import ContextMenuNode from './ContextMenu/ContextMenuNode.vue'
import {
  BIOLOGICAL_ASSOCIATION,
  BIOLOGICAL_ASSOCIATIONS_GRAPH
} from 'constants/index.js'

const {
  addCitation,
  addBiologicalRelationship,
  addObject,
  currentGraph,
  edges,
  getBiologicalRelationshipsByNodeId,
  isGraphUnsaved,
  isSaving,
  layouts,
  loadGraph,
  nodes,
  removeEdge,
  removeNode,
  resetStore,
  reverseRelation,
  saveBiologicalAssociations,
  selectedEdges,
  selectedNodes,
  setNodePosition,
  currentNodes,
  save,
  citations
} = useGraph()

const graph = ref()
const nodeType = ref()

const edgeContextMenu = ref()
const nodeContextMenu = ref()
const viewContextMenu = ref()

const showModalNode = ref(false)
const showModalEdge = ref(false)
const showModalCitation = ref(false)

const currentObjectType = ref()
const currentNodeId = ref()
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
  edgeContextMenu.value.openContextMenu(currentEvent.value)
}

function handleEvent(event) {
  event.stopPropagation()
  event.preventDefault()
  currentEvent.value = event
}

function handleCitationModal(citationData) {
  switch (currentObjectType.value) {
    case BIOLOGICAL_ASSOCIATION:
      addCitation({
        citationData,
        type: BIOLOGICAL_ASSOCIATION,
        uuid: graph.value.uuid
      })
      break
    case BIOLOGICAL_ASSOCIATIONS_GRAPH:
      addCitation({
        citationData,
        type: BIOLOGICAL_ASSOCIATIONS_GRAPH,
        uuid: graph.value.uuid
      })
      break
  }

  showModalCitation.value = false
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

function openNodeModal({ type }) {
  nodeType.value = type
  showModalNode.value = true
}

function openEdgeModal() {
  showModalEdge.value = true
}

function openCitationModal({ type }) {
  currentObjectType.value = type
  showModalCitation.value = true
}

function setGraph(graphId) {
  loadGraph(graphId).then((_) => {
    graph.value.fitToContents()
  })
}

defineExpose({
  addObject,
  currentNodes,
  openEdgeModal,
  openNodeModal,
  resetStore,
  saveBiologicalAssociations,
  setGraph,
  isGraphUnsaved,
  save
})
</script>

<style lang="scss" scoped>
.graph {
  width: calc(100vw - 2em);
  height: calc(100vh - 250px);
}
</style>
