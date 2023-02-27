<template>
  <VNetworkGraph
    ref="graph"
    class="graph panel"
    :configs="configs"
    :edges="edges"
    :nodes="nodes"
    :event-handlers="eventHandlers"
    v-model:selected-nodes="computedSelectedNodes"
    v-model:layouts="computedLayouts"
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
    :position="currentEvent"
  >
    <div
      class="graph-context-menu-list-item"
      @click="
        () => {
          emit('add:node', { type: OTU })
        }
      "
    >
      Add OTU
    </div>
    <div
      class="graph-context-menu-list-item"
      @click="
        () => {
          emit('add:node', { type: COLLECTION_OBJECT })
        }
      "
    >
      Add Collection object
    </div>
  </GraphContextMenu>

  <GraphContextMenu
    ref="nodeContextMenu"
    :position="currentEvent"
  >
    <div class="flex-separate middle gap-small graph-context-menu-list-item">
      <span>{{ nodes[currentNodeId]?.name }}</span>
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
      v-if="selectedNodes.length === 2"
      @click="() => emit('add:edge', selectedNodes)"
    >
      Create relation
    </div>
  </GraphContextMenu>

  <GraphContextMenu
    ref="edgeContextMenu"
    :position="currentEvent"
  >
    <div
      v-for="edgeId in currentEdge"
      :key="edgeId"
      class="flex-separate middle gap-small graph-context-menu-list-item"
    >
      {{ edges[edgeId]?.label }}
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
          :color="edges[edgeId].id ? 'destroy' : 'primary'"
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
        {{ edges[edgeId]?.label }}
        <div class="horizontal-right-content gap-xsmall">
          <VBtn
            color="primary"
            class="circle-button"
            @click="() => emit('reverse:edge', edgeId)"
          >
            <VIcon
              name="swap"
              x-small
            />
          </VBtn>
          <VBtn
            circle
            :color="edges[edgeId].id ? 'destroy' : 'primary'"
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
import { configs } from '../constants/networkConfig'
import { graphLayout } from '../utils/graphLayout.js'
import { COLLECTION_OBJECT, OTU } from 'constants/index.js'
import GraphContextMenu from './ContextMenu/ContextMenu.vue'
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

  layouts: {
    type: Object,
    default: () => ({})
  },

  selectedNodes: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits([
  'add:edge',
  'add:node',
  'remove:edge',
  'remove:node',
  'reverse:edge',
  'update:layouts',
  'update:selectedNodes',
  'view:position'
])

const graph = ref()
const edgeContextMenu = ref()
const nodeContextMenu = ref()
const viewContextMenu = ref()

const currentNodeId = ref()
const currentEdge = ref()
const currentEvent = ref()

const computedLayouts = computed({
  get: () => props.layouts,
  set: (value) => emit('update:layouts', value)
})

const computedSelectedNodes = computed({
  get: () => props.selectedNodes,
  set: (value) => emit('update:selectedNodes', value)
})

const isCurrentNodeSaved = computed(() =>
  Object.values(props.edges)
    .filter(
      (edge) =>
        edge.id &&
        (currentNodeId.value === edge.source ||
          currentNodeId.value === edge.target)
    )
    .map((edge) => edge.id)
)

function showViewContextMenu({ event }) {
  const point = { x: event.offsetX, y: event.offsetY }

  handleEvent(event)
  emit('view:position', graph.value.translateFromDomToSvgCoordinates(point))
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
  currentEvent.value = event
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
    emit('remove:node', node)
  }
}

async function removeEdge(edgeId) {
  const ok =
    !props.edges[edgeId].id ||
    (await confirmationModalRef.value.show({
      title: 'Destroy biological association',
      message:
        'This will delete the biological association. Are you sure you want to proceed?',
      okButton: 'Destroy',
      cancelButton: 'Cancel',
      typeButton: 'delete'
    }))

  if (ok) {
    emit('remove:edge', edgeId)
  }
}

function updateLayout(direction) {
  graph.value?.transitionWhile(() => {
    const { layouts, viewBox } = graphLayout({
      direction,
      nodes: props.nodes,
      edges: props.edges,
      nodeSize: 40
    })

    computedLayouts.value = layouts
    graph.value.setViewBox(viewBox)
  })
}

defineExpose({
  updateLayout
})
</script>

<style lang="scss" scoped>
.graph {
  width: calc(100vw - 2em);
  height: calc(100vh - 250px);
}
</style>
