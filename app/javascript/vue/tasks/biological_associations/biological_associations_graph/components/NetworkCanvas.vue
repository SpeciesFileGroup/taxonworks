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
    ref="viewContextMenu"
    :position="store.currentEvent"
  >
    <ContextMenuView />
  </GraphContextMenu>

  <GraphContextMenu
    ref="nodeContextMenu"
    :position="store.currentEvent"
  >
    <div class="flex-separate middle gap-small graph-context-menu-list-item">
      <span>{{ store.getNodes[currentNodeId]?.name }}</span>
      <VBtn
        circle
        :color="isCurrentNodeSaved ? 'destroy' : 'primary'"
        @click="() => removeNode(currentNodeId)"
      >
        <VIcon
          x-small
          name="trash"
        />
      </VBtn>
    </div>
    <div
      class="graph-context-menu-list-item"
      v-if="store.selectedNodes.length === 2"
      @click="() => (store.modal.edge = true)"
    >
      Create relation
    </div>
  </GraphContextMenu>

  <GraphContextMenu
    ref="edgeContextMenu"
    :position="store.currentEvent"
  >
    <div
      v-for="edgeId in currentEdge"
      :key="edgeId"
      class="flex-separate middle gap-small graph-context-menu-list-item"
    >
      {{ store.edges[edgeId]?.label }}
      <div class="horizontal-right-content gap-xsmall">
        <VBtn
          color="primary"
          class="circle-button"
          @click="
            () => {
              emit('reverse:edge', edgeId)
            }
          "
        >
          <VIcon
            name="swap"
            x-small
          />
        </VBtn>
        <VBtn
          circle
          :color="store.edges[edgeId].id ? 'destroy' : 'primary'"
          @click="
            () => {
              removeEdge(edgeId)
            }
          "
        >
          <VIcon
            x-small
            name="trash"
          />
        </VBtn>
      </div>
    </div>
    <ContextMenuEdge>
      <div
        v-for="edgeId in store.currentEdge"
        :key="edgeId"
        class="flex-separate middle gap-small graph-context-menu-list-item"
      >
        {{ store.edges[edgeId]?.label }}
        <div class="horizontal-right-content gap-xsmall">
          <VBtn
            color="primary"
            class="circle-button"
            @click="
              () => {
                store.reverseRelation(edgeId)
              }
            "
          >
            <VIcon
              name="swap"
              x-small
            />
          </VBtn>
          <VBtn
            circle
            :color="store.edges[edgeId].id ? 'destroy' : 'primary'"
            @click="
              () => {
                removeEdge(edgeId)
              }
            "
          >
            <VIcon
              x-small
              name="trash"
            />
          </VBtn>
        </div>
      </div>
    </ContextMenuEdge>
  </GraphContextMenu>

  <ConfirmationModal ref="confirmationModalRef" />
</template>

<script setup>
import { computed, ref } from 'vue'
import { useGraphStore } from '../store/useGraphStore.js'
import { configs } from '../constants/networkConfig'
import { graphLayout } from '../utils/graphLayout.js'
import GraphContextMenu from './ContextMenu/ContextMenu.vue'
import ContextMenuView from './ContextMenu/ContextMenuView.vue'
import ContextMenuEdge from './ContextMenu/ContextMenuEdge.vue'
import ConfirmationModal from 'components/ConfirmationModal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  nodes: {
    type: Object,
    default: () => ({})
  },

  edges: {
    type: Object,
    default: () => ({})
  },

  layout: {
    type: Object,
    default: () => ({})
  }
})

const store = useGraphStore()

const emit = defineEmits(['reverse:edge', 'remove:node'])

const graph = ref()
const edgeContextMenu = ref()
const nodeContextMenu = ref()
const viewContextMenu = ref()

const currentNodeId = ref()
const currentEdge = ref()

const isCurrentNodeSaved = computed(
  () => store.getCreatedAssociationsByNodeId(currentNodeId.value).length > 0
)

function showViewContextMenu({ event }) {
  const point = { x: event.offsetX, y: event.offsetY }

  handleEvent(event)

  store.currentSVGCursorPosition =
    graph.value.translateFromDomToSvgCoordinates(point)

  viewContextMenu.value.openContextMenu()
}

function showNodeContextMenu({ node, event }) {
  handleEvent(event)
  currentNodeId.value = node
  nodeContextMenu.value.openContextMenu()
}

function showEdgeContextMenu({ event, summarized, edges, edge }) {
  handleEvent(event)
  currentEdge.value = summarized ? edges : [edge]
  edgeContextMenu.value.openContextMenu()
}

function handleEvent(event) {
  event.stopPropagation()
  event.preventDefault()
  store.currentEvent = event
}

const eventHandlers = {
  'view:contextmenu': showViewContextMenu,
  'node:contextmenu': showNodeContextMenu,
  'edge:contextmenu': showEdgeContextMenu
}

const confirmationModalRef = ref()

async function removeNode(node) {
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
    store.removeNode(node)
  }
}

async function removeEdge(edgeId) {
  const ok =
    !store.edges[edgeId].id ||
    (await confirmationModalRef.value.show({
      title: 'Destroy biological association',
      message:
        'This will delete the biological association. Are you sure you want to proceed?',
      okButton: 'Destroy',
      cancelButton: 'Cancel',
      typeButton: 'delete'
    }))

  if (ok) {
    store.removeEdge(edgeId)
  }
}

function updateLayout(direction) {
  graph.value?.transitionWhile(() => {
    const { layouts, viewBox } = graphLayout({
      direction,
      graphRef: graph,
      nodes: store.nodes,
      edges: store.edges,
      nodeSize: 40
    })

    store.layouts = layouts
    graph.value.setViewBox(viewBox)
  })
}

store.$onAction(({ name, after }) => {
  after(() => {
    if (name === 'loadGraph') updateLayout('LR')
  })
})
</script>

<style lang="scss" scoped>
.graph {
  width: calc(100vw - 2em);
  height: calc(100vh - 250px);
}
</style>
