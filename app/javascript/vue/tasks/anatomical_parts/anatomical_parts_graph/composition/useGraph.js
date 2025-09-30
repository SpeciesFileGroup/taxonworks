import { reactive, computed, toRefs } from 'vue'
import {
  AnatomicalPart
} from '@/routes/endpoints'
import {
  nodeAnatomicalPartStyle,
  nodeCollectionObjectStyle,
  nodeExtractStyle,
  nodeFieldOccurrenceStyle,
  nodeOtuStyle,
  nodeSequenceStyle,
  nodeSoundStyle
} from '../constants/graphStyle.js'
import {
  makeNodeId,
} from '../utils/index.js'
import { randomUUID } from '@/helpers'
import {
  ANATOMICAL_PART,
  COLLECTION_OBJECT,
  EXTRACT,
  FIELD_OCCURRENCE,
  OTU,
  SEQUENCE,
  SOUND
} from '@/constants/index.js'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { getHexColorFromString } from '@/tasks/biological_associations/biological_associations_graph/utils/textToHex.js'

function initState() {
  return {
    nodeObjects: [],
    edgeObjects: [],
    layouts: {
      nodes: {}
    },
    isLoading: false,
    graph: makeGraph()
  }
}

function makeGraph() {
  return {
    uuid: randomUUID()
  }
}

function getNodeStyleByType(objectType) {
  const styles = {
    [ANATOMICAL_PART]: nodeAnatomicalPartStyle,
    [COLLECTION_OBJECT]: nodeCollectionObjectStyle,
    [EXTRACT]: nodeExtractStyle,
    [FIELD_OCCURRENCE]: nodeFieldOccurrenceStyle,
    [OTU]: nodeOtuStyle,
    [SEQUENCE]: nodeSequenceStyle,
    [SOUND]: nodeSoundStyle
  }

  return styles[objectType]
}

export function useGraph() {
  const state = reactive(initState())

  const nodes = computed(() => {
    return Object.fromEntries(
      state.nodeObjects.map((obj) => {
        const nodeId = makeNodeId(obj)
        const node = {
          name: obj.object_label
        }

        Object.assign(node, getNodeStyleByType(obj.object_type))

        return [nodeId, node]
      })
    )
  })

  const edges = computed(() => {
    const edges = state.edgeObjects.map((r) => {
      const oldNode = relationshipOldNode(r)
      const newNode = relationshipNewNode(r)
      const edgeObject = {
        id: r.id,
        source: makeNodeId(oldNode),
        target: makeNodeId(newNode),
        label: 'my label',
        color: getHexColorFromString(oldNode.object_type + newNode.object_type)
      }

      return [r.uuid, edgeObject]
    })

    return Object.fromEntries(edges)
  })

  const currentGraph = computed(() => state.graph)
  const currentNodes = computed(() => state.selectedNodes)

  function resetStore() {
    Object.assign(state, initState())
  }

  function getObjectByUuid(uuid) {
    return [state.graph, ...state.biologicalAssociations].find(
      (item) => item.uuid === uuid
    )
  }

  async function loadGraph(idsHash) {
    state.isLoading = true

    let graph = makeGraph()
    // TODO: handle empty idsHash
    const graphParts = await AnatomicalPart.graph(winnowIdsHash(idsHash))

    resetStore()
    state.graph = graph
    state.nodeObjects = addUUID(graphParts.body.nodes)
    state.edgeObjects = addUUID(graphParts.body.origin_relationships)

    state.isLoading = false

    return graph
  }

  // idsHash, of the form {otu_id: a, collection_object_id: b, ...} should have no more than 1 non-null id.
  function winnowIdsHash(idsHash) {
    let rv = null
    Object.keys(idsHash).forEach((key) => {
      if (idsHash[key]) {
        const type = Object.keys(ID_PARAM_FOR).filter((param) => ID_PARAM_FOR[param] == key)[0]

        rv = {
          type,
          id: idsHash[key]
        }
      }
    })

    return rv || false
  }

  function relationshipOldNode(r) {
    return state.nodeObjects.find((o) => (o.id == r.old_object_id && o.object_type == r.old_object_type))
  }

  function relationshipNewNode(r) {
    return state.nodeObjects.find((o) => (o.id == r.new_object_id && o.object_type == r.new_object_type))
  }

  function addUUID(a) {
    return a.map((o) => ({...o, uuid: randomUUID()}))
  }

  return {
    currentGraph,
    currentNodes,
    edges,
    getObjectByUuid,
    loadGraph,
    nodes,
    resetStore,
    ...toRefs(state)
  }
}
