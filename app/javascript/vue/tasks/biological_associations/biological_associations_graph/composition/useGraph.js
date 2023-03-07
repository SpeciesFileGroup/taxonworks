import { reactive, computed, toRefs } from 'vue'
import { BiologicalAssociation, BiologicalAssociationGraph } from 'routes/endpoints'
import { makeBiologicalAssociation, makeNodeObject } from '../adapters'
import {
  unsavedEdge,
  nodeCollectionObjectStyle,
  nodeOtuStyle,
  unsavedNodeStyle
} from '../constants/graphStyle.js'
import { parseNodeId, makeNodeId, isEqualNodeObject, isNetwork } from '../utils'
import { COLLECTION_OBJECT } from 'constants/index.js'

const EXTEND_GRAPH = [
  'biological_associations_biological_associations_graphs',
  'biological_associations'
]

const EXTEND_BA = ['subject', 'object', 'biological_relationship']

function initState() {
  return {
    biologicalAssociations: [],
    nodeObjects: [],
    selectedNodes: [],
    layouts: {
      nodes: {}
    },
    settings: {
      isSaving: false
    },
    graph: {
      biological_association_id: []
    }
  }
}

export function useGraph() {
  const state = reactive(initState())

  const nodes = computed(() =>
    Object.fromEntries(
      state.nodeObjects.map((obj) => {
        const nodeId = makeNodeId(obj)
        const isSaved = getBiologicalRelationshipsByNodeId(nodeId).some((ba) => !!ba.id)
        const node = {
          name: obj.name
        }

        Object.assign(
          node,
          obj.objectType === COLLECTION_OBJECT ? nodeCollectionObjectStyle : nodeOtuStyle
        )

        if (!isSaved) {
          Object.assign(node, unsavedNodeStyle)
        }

        return [nodeId, node]
      })
    )
  )

  const edges = computed(() =>
    Object.fromEntries(
      state.biologicalAssociations.map((ba) => {
        const edgeObject = {
          id: ba.id,
          source: makeNodeId(ba.subject),
          target: makeNodeId(ba.object),
          label: ba.biologicalRelationship.name
        }

        if (ba.isUnsaved) {
          Object.assign(edgeObject, unsavedEdge)
        }

        return [ba.uuid, edgeObject]
      })
    )
  )

  const currentGraph = computed(() => state.graph)
  const currentNodes = computed(() => state.selectedNodes)

  function resetStore() {
    Object.assign(state, initState())
  }

  const getBiologicalRelationshipsByNodeId = (nodeId) => {
    const obj = parseNodeId(nodeId)

    return state.biologicalAssociations.filter((ba) => {
      return isEqualNodeObject(ba.object, obj) || isEqualNodeObject(ba.subject, obj)
    })
  }

  const isGraphUnsaved = computed(() => state.biologicalAssociations.some((ba) => ba.isUnsaved))

  function addBiologicalRelationship({ subjectNodeId, objectNodeId, relationship }) {
    const nObj = parseNodeId(subjectNodeId)
    const nSub = parseNodeId(objectNodeId)

    const subject = state.nodeObjects.find((o) => isEqualNodeObject(o, nSub))
    const object = state.nodeObjects.find((o) => isEqualNodeObject(o, nObj))

    const biologicalAssociation = {
      id: undefined,
      uuid: crypto.randomUUID(),
      subject,
      object,
      biologicalRelationship: relationship,
      isUnsaved: true
    }

    state.biologicalAssociations.push(biologicalAssociation)
  }

  function reverseRelation(uuid) {
    const ba = state.biologicalAssociations.find((ba) => ba.uuid === uuid)

    Object.assign(ba, {
      subject: ba.object,
      object: ba.subject,
      isUnsaved: true
    })
  }

  function setNodePosition(nodeId, position) {
    state.layouts.nodes[nodeId] = position
  }

  function addObject(obj) {
    if (!state.nodeObjects.some((item) => isEqualNodeObject(item, obj))) {
      state.nodeObjects.push(obj)
    }
  }

  async function loadGraph(graphId) {
    const { body } = await BiologicalAssociationGraph.find(graphId, {
      extend: EXTEND_GRAPH
    })
    const baIds = body.biological_associations_biological_associations_graphs.map(
      (ba) => ba.biological_association_id
    )

    resetStore()
    state.graph = body
    state.layouts = JSON.parse(body.layout)

    if (baIds.length) {
      await BiologicalAssociation.where({
        biological_association_id: baIds,
        extend: EXTEND_BA
      }).then(({ body }) => {
        body.forEach((item) => {
          const ba = makeBiologicalAssociation(item)

          addObject(ba.subject)
          addObject(ba.object)
          state.biologicalAssociations.push(ba)
        })
      })
    }

    return body
  }

  function removeEdge(edgeId) {
    const index = state.biologicalAssociations.findIndex((ba) => ba.uuid === edgeId)
    const ba = state.biologicalAssociations[index]

    if (ba.id) {
      BiologicalAssociation.destroy(ba.id).then((_) => {
        TW.workbench.alert.create('Biological association was successfully deleted.', 'notice')
      })
    }

    state.biologicalAssociations.splice(index, 1)
  }

  function removeNode(nodeId) {
    const biologicalAssociations = getBiologicalRelationshipsByNodeId(nodeId)
    const created = biologicalAssociations.filter(({ id }) => id)
    const nodeObject = makeNodeObject(nodeId)

    biologicalAssociations.forEach((ba) => {
      removeEdge(ba.uuid)
    })

    const message =
      created.length > 1
        ? 'Biological association(s) were successfully deleted.'
        : 'Biological association was successfully deleted.'

    TW.workbench.alert.create(message, 'notice')

    removeNodeObject(nodeObject)

    state.biologicalAssociations = state.biologicalAssociations.filter(({ uuid }) =>
      biologicalAssociations.some((ba) => ba.uuid !== uuid)
    )
  }

  function removeNodeObject(obj) {
    const index = state.nodeObjects.findIndex((o) => isEqualNodeObject(o, obj))

    state.nodeObjects.splice(index, 1)
  }

  function saveBiologicalAssociations() {
    const biologicalAssociations = state.biologicalAssociations.filter((ba) => ba.isUnsaved)

    const requests = biologicalAssociations.map((ba) => {
      const { biologicalRelationship, object, subject, id } = ba
      const payload = {
        biological_association: {
          biological_relationship_id: biologicalRelationship.id,
          biological_association_object_id: object.id,
          biological_association_object_type: object.objectType,
          biological_association_subject_id: subject.id,
          biological_association_subject_type: subject.objectType
        }
      }

      const request = id
        ? BiologicalAssociation.update(id, payload)
        : BiologicalAssociation.create(payload)

      request.then(({ body }) => {
        ba.id = body.id
        ba.isUnsaved = false
      })

      return request
    })

    return Promise.all(requests)
  }

  async function save() {
    const createdBiologicalAssociations = await saveBiologicalAssociations()

    if (isNetwork(state.biologicalAssociations) || state.graph.id) {
      return saveGraph()
    }

    return createdBiologicalAssociations
  }

  function saveGraph() {
    const biologicalAssociationsSaved = state.biologicalAssociations.filter((r) => r.id)
    const biologicalAssociationsInGraph = (
      state.graph.biological_associations_biological_associations_graphs || []
    ).map((obj) => obj.biological_association_id)

    const payload = {
      biological_associations_graph: {
        layout: JSON.stringify(state.layouts),
        biological_associations_biological_associations_graphs_attributes:
          biologicalAssociationsSaved
            .filter((ba) => !biologicalAssociationsInGraph.includes(ba.id))
            .map((r) => ({
              biological_association_id: r.id
            }))
      },
      extend: EXTEND_GRAPH
    }

    const request = state.graph.id
      ? BiologicalAssociationGraph.update(state.graph.id, payload)
      : BiologicalAssociationGraph.create(payload)

    request.then(({ body }) => {
      state.graph = body
    })

    return request
  }

  return {
    addBiologicalRelationship,
    addObject,
    currentGraph,
    currentNodes,
    edges,
    getBiologicalRelationshipsByNodeId,
    isGraphUnsaved,
    loadGraph,
    nodes,
    removeEdge,
    removeNode,
    resetStore,
    reverseRelation,
    save,
    saveBiologicalAssociations,
    setNodePosition,
    ...toRefs(state)
  }
}
