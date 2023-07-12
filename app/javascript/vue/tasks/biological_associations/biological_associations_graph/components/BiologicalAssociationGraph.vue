<template>
  <slot
    name="header"
    :selected-nodes="selectedNodes"
    :is-graph-unsaved="isGraphUnsaved"
    :edges="edges"
    :current-graph="currentGraph"
    :source-ids="getSourceIds()"
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
      <template #edge-overlay="{ scale, pointAtLength, edgeId, edge }">
        <g
          v-if="getObjectByUuid(edgeId)?.citations.length"
          class="edge-icon"
          @contextmenu.stop="
            ($event) => {
              $event.preventDefault()
              openCitationModalFor([edgeId])
            }
          "
        >
          <circle
            :cx="pointAtLength(40 * scale).x"
            :cy="pointAtLength(40 * scale).y"
            :r="10 * scale"
            :stroke="edge.color"
            :stroke-width="2 * scale"
            :fill="edge.sourceState === 'off' ? '#fcc' : '#fff'"
          />
          <path
            v-if="getObjectByUuid(edgeId)?.citations.length"
            class="marker"
            :fill="configs.edge.normal.color(edge)"
            :transform="makeTransform(pointAtLength(40 * scale), scale, 1.0)"
            d="M5.9-2.1L4,4.5C3.8,5.1,3.1,5.5,2.5,5.5h-6.6c-0.7,0-1.5-0.6-1.8-1.3C-6,3.9-6,3.6-5.9,3.3c0-0.2,0-0.3,0-0.5
		c0-0.1-0.1-0.2,0-0.3c0-0.2,0.2-0.3,0.3-0.5c0.2-0.4,0.5-0.9,0.5-1.3c0-0.1,0-0.3,0-0.4c0-0.1,0.2-0.2,0.2-0.4
		c0.2-0.3,0.5-1,0.5-1.3c0-0.2-0.1-0.3,0-0.4C-4.4-2-4.2-2-4.1-2.2c0.2-0.2,0.5-0.9,0.5-1.3c0-0.1-0.1-0.2,0-0.4
		c0-0.1,0.2-0.3,0.3-0.5C-3-4.8-2.9-5.7-2-5.5v0c0.1,0,0.2-0.1,0.4-0.1h5.5c0.3,0,0.6,0.2,0.8,0.4c0.2,0.3,0.2,0.6,0.1,0.9L2.8,2.3
		C2.5,3.5,2.3,3.7,1.4,3.7h-6.3c-0.1,0-0.2,0-0.3,0.1s-0.1,0.2,0,0.3c0.2,0.4,0.6,0.5,1,0.5h6.6c0.3,0,0.6-0.2,0.6-0.4l2.2-7.1
		c0-0.1,0-0.3,0-0.4C5.5-3.2,5.7-3.1,5.8-3C6-2.7,6-2.4,5.9-2.1z M-2.3-0.9h4.4c0.1,0,0.3-0.1,0.3-0.2l0.2-0.5c0-0.1,0-0.2-0.2-0.2
		H-2c-0.1,0-0.3,0.1-0.3,0.2l-0.2,0.5C-2.5-1-2.4-0.9-2.3-0.9z M-1.7-2.8h4.4C2.8-2.8,2.9-2.9,3-3l0.2-0.5c0-0.1,0-0.2-0.2-0.2h-4.4
		c-0.1,0-0.3,0.1-0.3,0.2L-1.8-3C-1.9-2.9-1.8-2.8-1.7-2.8z"
          />
        </g>
      </template>
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
        :is-graph="isNetwork(biologicalAssociations)"
        @add:node="openNodeModal"
        @cite:graph="() => openCitationModalFor([currentGraph.uuid])"
      />
    </ContextMenu>

    <ContextMenu ref="nodeContextMenu">
      <ContextMenuNode
        :node="nodes[currentNodeId]"
        :node-id="currentNodeId"
        :is-saved="isCurrentNodeSaved"
        :has-relationship="
          !!getBiologicalRelationshipsByNodeId(currentNodeId).length
        "
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

    <ModalGraph
      v-if="showModalGraph"
      :graph="currentGraph"
      @update:name="
        ($event) => {
          setGraphName($event)
          saveGraph()
          showModalGraph = false
        }
      "
      @close="() => (showModalGraph = false)"
    />

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

    <ModalSource
      v-if="showModalSource"
      :source-id="getSourceIds()"
      @close="() => (showModalSource = false)"
    />

    <ConfirmationModal ref="confirmationModalRef" />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { configs } from '../constants/networkConfig'
import { useGraph } from '../composition/useGraph.js'
import { makeNodeId, isNetwork } from '../utils'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import ModalGraph from './ModalGraph.vue'
import ModalCitation from './ModalCitation.vue'
import ModalObject from './ModalObject.vue'
import ModalSource from './ModalSource.vue'
import ModalEdge from './ModalEdge.vue'
import VSpinner from '@/components/spinner.vue'
import ContextMenu from './ContextMenu/ContextMenu.vue'
import ContextMenuEdge from './ContextMenu/ContextMenuEdge.vue'
import ContextMenuView from './ContextMenu/ContextMenuView.vue'
import ContextMenuNode from './ContextMenu/ContextMenuNode.vue'
import { makeNodeObject } from '../adapters'

const emit = defineEmits('load:graph')

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
  getSourceIds,
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
  saveGraph,
  selectedEdges,
  selectedNodes,
  setGraphName,
  setNodePosition,
  updateObjectByUuid
} = useGraph()

const graph = ref()
const nodeType = ref()

const edgeContextMenu = ref()
const nodeContextMenu = ref()
const viewContextMenu = ref()

const showModalNode = ref(false)
const showModalEdge = ref(false)
const showModalGraph = ref(false)
const showModalCitation = ref(false)
const showModalSource = ref(false)

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

function openGraphModal() {
  showModalGraph.value = true
}

function openSourceModal() {
  showModalSource.value = true
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

function makeTransform(position, scale, width) {
  const posX = position.x
  const posY = position.y

  return [
    `translate(${posX} ${posY})`,
    `scale(${scale * width}, ${scale * width})`
  ].join(' ')
}

function addNodeObject(obj) {
  addObject(makeNodeObject(obj))
}

async function downloadAsSvg() {
  if (!graph.value) return
  const text = await graph.value.exportAsSvgText()
  const url = URL.createObjectURL(new Blob([text], { type: 'octet/stream' }))
  const a = document.createElement('a')
  a.href = url
  a.download = 'network-graph.svg'
  a.click()
  window.URL.revokeObjectURL(url)
}

function getBiologicalRelationships() {
  return biologicalAssociations
}

defineExpose({
  addNodeObject,
  currentNodes,
  getBiologicalRelationships,
  isGraphUnsaved,
  loadBiologicalAssociations,
  openEdgeModal,
  openGraphModal,
  openNodeModal,
  openSourceModal,
  resetStore,
  save,
  saveBiologicalAssociations,
  setGraph,
  downloadAsSvg,
  updateObjectByUuid
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
