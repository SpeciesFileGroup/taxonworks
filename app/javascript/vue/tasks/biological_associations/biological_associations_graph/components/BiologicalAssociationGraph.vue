<template>
  <slot
    name="header"
    :selected-nodes="selectedNodes"
    :is-graph-unsaved="isGraphUnsaved"
    :edges="edges"
    :current-graph="currentGraph"
  />
  <div
    class="panel relative"
    v-help.canvas
  >
    <VSpinner
      v-if="isSaving"
      full-screen
      legend="Saving biological associations..."
    />

    <VSpinner
      v-if="isLoading"
      legend="Loading biological associations graph..."
    />
    <div
      v-if="!Object.keys(nodes).length"
      id="background"
    >
      <h2 class="subtle">Right-click canvas to begin</h2>
    </div>
    <VNetworkGraph
      ref="graph"
      class="graph"
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
        :title="currentGraph.label"
        :count="biologicalAssociations.length"
        :citations="currentGraph.citations.length"
        @add:node="openNodeModal"
        @cite:graph="() => openCitationModalFor([currentGraph.uuid])"
      />
    </ContextMenu>

    <ContextMenu ref="nodeContextMenu">
      <ContextMenuNode
        :node="nodes[currentNodeId]"
        :node-id="currentNodeId"
        :is-saved="isCurrentNodeSaved"
        :create-button="selectedNodes.length === 2"
        :citations="
          getBiologicalRelationshipsByNodeId(currentNodeId).reduce(
            (acc, curr) => acc + curr.citations.length,
            0
          )
        "
        @remove:node="handleRemoveNode"
        @add:edge="openEdgeModal"
        @cite:edge="
          () =>
            openCitationModalFor(
              getBiologicalRelationshipsByNodeId(currentNodeId).map(
                (item) => item.uuid
              )
            )
        "
      />
    </ContextMenu>

    <ContextMenu ref="edgeContextMenu">
      <ContextMenuEdge
        :edges="edges"
        :selected-edge-ids="selectedEdges"
        :citations="
          selectedEdges.reduce(
            (acc, curr) => acc + getObjectByUuid(curr).citations.length,
            0
          )
        "
        @cite:edge="() => openCitationModalFor(selectedEdges)"
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
      :items="currentCitationObjects"
      @add:citation="handleCitationModal"
      @close="() => (showModalCitation = false)"
      @remove:citation="removeCitationFor"
    />

    <ConfirmationModal ref="confirmationModalRef" />
  </div>
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

const {
  addBiologicalRelationship,
  addCitationFor,
  addObject,
  biologicalAssociations,
  currentGraph,
  currentNodes,
  edges,
  getBiologicalRelationshipsByNodeId,
  getObjectByUuid,
  isGraphUnsaved,
  isLoading,
  isSaving,
  layouts,
  loadBiologicalAssociations,
  loadGraph,
  nodes,
  removeCitationFor,
  removeEdge,
  removeNode,
  resetStore,
  reverseRelation,
  save,
  saveBiologicalAssociations,
  selectedEdges,
  selectedNodes,
  setNodePosition
} = useGraph()

const graph = ref()
const nodeType = ref()

const edgeContextMenu = ref()
const nodeContextMenu = ref()
const viewContextMenu = ref()

const showModalNode = ref(false)
const showModalEdge = ref(false)
const showModalCitation = ref(false)

const currentCitationObjects = ref([])
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

function handleCitationModal({ citationData, items }) {
  items.forEach((item) => {
    addCitationFor(item, citationData)
  })

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

function openCitationModalFor(items) {
  currentCitationObjects.value = items.map((item) => getObjectByUuid(item))
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
  isGraphUnsaved,
  loadBiologicalAssociations,
  openEdgeModal,
  openNodeModal,
  resetStore,
  save,
  saveBiologicalAssociations,
  setGraph
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
  width: calc(100vw - 2em);
  height: calc(100vh - 250px);
}
</style>
