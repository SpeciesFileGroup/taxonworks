<template>
  <div class="ba-network">
    <VSkeleton
      variant="rect"
      height="560px"
      v-if="isLoading"
    />

    <template v-else-if="biologicalAssociations.length">
      <div class="ba-network__toolbar">
        <span
          v-for="type in objectTypes"
          :key="key"
          class="ba-network__legend"
        >
          <span
            class="ba-network__legend-dot"
            :style="{ background: getNodeStyleByType(type).color }"
          />
          {{ type }}
        </span>
        <span class="ba-network__hint"> swipe to pan · scroll to zoom </span>
      </div>

      <VNetworkGraph
        class="ba-network__canvas"
        :nodes="nodes"
        :edges="edges"
        :configs="graphConfigs"
        :event-handlers="eventHandlers"
        :layouts="layouts"
      >
        <template #edge-label="{ edge, ...slotProps }">
          <v-edge-label
            :text="edge.label"
            align="center"
            vertical-align="above"
            v-bind="slotProps"
          />
        </template>
      </VNetworkGraph>
    </template>
    <div v-else>No related associations found.</div>
  </div>
</template>

<script setup>
import { ref, computed, reactive, onBeforeMount } from 'vue'
import { VNetworkGraph, defineConfigs, VEdgeLabel } from 'v-network-graph'
import { ForceLayout } from 'v-network-graph/lib/force-layout'
import { BiologicalAssociation } from '@/routes/endpoints'
import { makeBrowseUrl } from '@/helpers'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import {
  COLLECTION_OBJECT,
  OTU,
  ANATOMICAL_PART,
  FIELD_OCCURRENCE
} from '@/constants'
import { networkConfig } from '@/tasks/biological_associations/biological_associations_graph/constants/networkConfig.js'
import {
  nodeCollectionObjectStyle,
  nodeFieldOccurrenceStyle,
  nodeOtuStyle,
  nodeAnatomicalPartStyle
} from '@/tasks/biological_associations/biological_associations_graph/constants/graphStyle.js'
import VSkeleton from '@/components/ui/VSkeleton/VSkeleton.vue'

const NODE_STYLES = {
  [COLLECTION_OBJECT]: nodeCollectionObjectStyle,
  [FIELD_OCCURRENCE]: nodeFieldOccurrenceStyle,
  [OTU]: nodeOtuStyle,
  [ANATOMICAL_PART]: nodeAnatomicalPartStyle
}

const props = defineProps({
  current: {
    type: Object,
    required: true
  },

  itemId: {
    type: Number,
    required: true
  },

  itemType: {
    type: String,
    required: true
  }
})

const isLoading = ref(false)
const biologicalAssociations = ref([])
const selectedNodeKey = ref(null)
const selectedEdgeKey = ref(null)

const layouts = reactive({ nodes: {} })

const objectTypes = computed(() => [
  ...new Set(
    biologicalAssociations.value
      .map((b) => [
        b.biological_association_subject_type,
        b.biological_association_object_type
      ])
      .flat()
  )
])

onBeforeMount(async () => {
  if (!biologicalAssociations.value.length) {
    isLoading.value = true

    const { body } = await BiologicalAssociation.all({
      [ID_PARAM_FOR[props.itemType]]: [props.itemId].flat(),
      extend: ['subject', 'object', 'biological_relationship']
    })

    biologicalAssociations.value = body /* .filter(
      (item) => item.id !== props.current.id
    ) */

    isLoading.value = false
  }
})

function getNodeStyleByType(objectType) {
  return NODE_STYLES[objectType]
}

/** Stable string key for a node given its type and numeric id. */
function nodeKey(type, id) {
  return `${type}_${id}`
}

/**
 * nodes – derived from unique subject/object pairs across all associations.
 * Each key is `${entityType}_${entityId}` to prevent ID collisions between
 * different entity types.
 */
const nodes = computed(() => {
  const map = new Map()

  const ensureNode = (type, id, data) => {
    const key = nodeKey(type, id)
    if (map.has(key)) return

    map.set(key, {
      name: data?.object_label ?? `${type} ${id}`,
      tag: data?.object_tag ?? '',
      entityId: id,
      entityType: type,
      browseUrl: makeBrowseUrl({ id, type }),

      ...getNodeStyleByType(type)
    })
  }

  for (const assoc of biologicalAssociations.value) {
    ensureNode(
      assoc.biological_association_subject_type,
      assoc.biological_association_subject_id,
      assoc.subject
    )

    ensureNode(
      assoc.biological_association_object_type,
      assoc.biological_association_object_id,
      assoc.object
    )
  }

  return Object.fromEntries(map)
})

/**
 * edges – one entry per association record.
 * Key is the association id (string) so v-network-graph can track it.
 */
const edges = computed(() => {
  const map = {}

  biologicalAssociations.value.forEach((assoc) => {
    const source = nodeKey(
      assoc.biological_association_subject_type,
      assoc.biological_association_subject_id
    )
    const target = nodeKey(
      assoc.biological_association_object_type,
      assoc.biological_association_object_id
    )

    map[String(assoc.id)] = {
      source,
      target,
      label: assoc.biological_relationship?.object_label ?? '',
      associationId: assoc.id
    }
  })

  return map
})

// ── Event handlers ─────────────────────────────────────────────────────

function onNodeClick(nodeId) {
  selectedEdgeKey.value = null
  selectedNodeKey.value = selectedNodeKey.value === nodeId ? null : nodeId
}

function onEdgeClick(edgeId) {
  selectedNodeKey.value = null
  selectedEdgeKey.value = selectedEdgeKey.value === edgeId ? null : edgeId
}

// Passed to :event-handlers prop; avoids inline closures in the template.
const eventHandlers = {
  'node:click': ({ node }) => onNodeClick(node),
  'edge:click': ({ edge }) => onEdgeClick(edge)
}

// ── Graph configuration ────────────────────────────────────────────────

const graphConfigs = defineConfigs({
  ...networkConfig,
  view: {
    scalingObjects: true,
    layoutHandler: new ForceLayout({
      createSimulation: (d3, nodes, edges) => {
        const forceLink = d3
          .forceLink(edges)
          .id((d) => d.id)
          .distance(260)
          .strength(0.2)

        const simulation = d3
          .forceSimulation(nodes)
          .force('link', forceLink)
          .force('charge', d3.forceManyBody().strength(-700))
          .force('collide', d3.forceCollide(90))
          .force('center', d3.forceCenter().strength(0.07))
          .alphaMin(0.001)

        return simulation
      }
    })
  }
})
</script>

<style scoped>
.ba-network {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.ba-network__canvas {
  width: 100%;
  height: 560px;
  border: 1px solid var(--border-color, #d5d5d5);
  border-radius: 4px;
  background-color: var(--panel-bg-color, #fafafa);
}

.ba-network__toolbar {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 0.8125rem;
}

.ba-network__legend {
  display: inline-flex;
  align-items: center;
  gap: 5px;
}

.ba-network__legend-dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.ba-network__hint {
  margin-left: auto;
  font-style: italic;
  font-size: 0.75rem;
}
</style>
