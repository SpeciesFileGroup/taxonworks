import { reactive, computed, toRefs } from 'vue'
import {
  BiologicalAssociation,
  BiologicalAssociationGraph
} from 'routes/endpoints'
import { makeBiologicalAssociation, makeNodeObject } from '../adapters'
import { unsavedEdge } from '../constants/graphStyle.js'
import { parseNodeId, makeNodeId, isEqualNodeObject } from '../utils'

const extend = [
  'biological_associations_biological_associations_graphs',
  'biological_associations'
]

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

const state = reactive(initState())

export function useGraph() {
  const nodes = computed(() =>
    Object.fromEntries(
      state.nodeObjects.map((obj) => [
        makeNodeId(obj),
        {
          name: obj.name
        }
      ])
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

  const getBiologicalRelationshipsByNodeId = (nodeId) => {
    const obj = parseNodeId(nodeId)

    return state.biologicalAssociations.filter((ba) => {
      return (
        isEqualNodeObject(ba.object, obj) || isEqualNodeObject(ba.subject, obj)
      )
    })
  }

  const isGraphUnsaved = computed(() =>
    state.biologicalAssociations.some((ba) => ba.isUnsaved)
  )

  function createBiologicalRelationship({
    subjectNodeId,
    objectNodeId,
    relationship
  }) {
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

  function isNetwork() {
    const subjects = state.biologicalAssociations.map((edge) => edge.subject)
    const objects = state.biologicalAssociations.map((edge) => edge.object)

    const uniqueObjects = [...new Set(objects)]
    const uniqueSubjects = [...new Set(subjects)]

    return (
      subjects.some((nodeId) => objects.includes(nodeId)) ||
      uniqueSubjects.length < subjects.length ||
      uniqueObjects.length < objects.length
    )
  }

  function setNodePosition(nodeId, position) {
    state.layouts.nodes[nodeId] = position
  }

  function resetStore() {
    Object.assign(state, initState())
  }

  function addObject(obj) {
    if (!state.nodeObjects.some((item) => isEqualNodeObject(item, obj))) {
      state.nodeObjects.push(obj)
    }
  }

  async function loadGraph(graphId) {
    const { body: graph } = await BiologicalAssociationGraph.find(graphId, {
      extend
    })
    const baIds =
      graph.biological_associations_biological_associations_graphs.map(
        (ba) => ba.biological_association_id
      )

    state.graph = graph

    return BiologicalAssociation.where({
      biological_association_id: baIds,
      extend: ['subject', 'object', 'biological_relationship']
    }).then(({ body }) => {
      body.forEach((item) => {
        const ba = makeBiologicalAssociation(item)

        addObject(ba.subject)
        addObject(ba.object)
        state.biologicalAssociations.push(ba)
      })
    })
  }

  function removeNode(nodeId) {
    const biologicalAssociations = getBiologicalRelationshipsByNodeId(nodeId)
    const created = biologicalAssociations.filter(({ id }) => id)
    const nodeObject = makeNodeObject(nodeId)

    if (created.length) {
      const requests = created.map(({ id }) =>
        BiologicalAssociation.destroy(id)
      )

      Promise.all(requests).then(() => {
        const message =
          created.length > 1
            ? 'Biological association(s) were successfully deleted.'
            : 'Biological association was successfully deleted.'

        TW.workbench.alert.create(message, 'notice')
      })
    }

    removeNodeObject(nodeObject)

    state.biologicalAssociations = state.biologicalAssociations.filter(
      ({ uuid }) => biologicalAssociations.some((ba) => ba.uuid !== uuid)
    )
  }

  function removeNodeObject(obj) {
    const index = state.nodeObjects.findIndex((o) => isEqualNodeObject(o, obj))

    state.nodeObjects.splice(index, 1)
  }

  function saveBiologicalAssociations() {
    const biologicalAssociations = state.biologicalAssociations.filter(
      (ba) => ba.isUnsaved
    )

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

    Promise.all(requests).then(async (_) => {
      if (isNetwork()) {
        const savedAssociations = state.biologicalAssociations.filter(
          (r) => r.id
        )
        const graphAssociations = (
          state.graph.biological_associations_biological_associations_graphs ||
          []
        ).map((obj) => obj.biological_association_id)

        const payload = {
          biological_associations_graph: {
            biological_associations_biological_associations_graphs_attributes:
              savedAssociations
                .filter((ba) => !graphAssociations.includes(ba.id))
                .map((r) => ({
                  biological_association_id: r.id
                }))
          },
          extend
        }

        const request = state.graph.id
          ? BiologicalAssociationGraph.update(state.graph.id, payload)
          : BiologicalAssociationGraph.create(payload)

        request.then(({ body }) => {
          state.graph = body
          TW.workbench.alert.create(
            'Biological associations graph was successfully saved.',
            'notice'
          )
        })
      } else {
        TW.workbench.alert.create(
          state.biologicalAssociations.length > 1
            ? 'Biological associations were successfully saved.'
            : 'Biological association was successfully saved.',
          'notice'
        )
      }
    })
  }

  return {
    resetStore,
    nodes,
    edges,
    loadGraph,
    addObject,
    setNodePosition,
    createBiologicalRelationship,
    reverseRelation,
    saveBiologicalAssociations,
    isGraphUnsaved,
    getBiologicalRelationshipsByNodeId,
    removeNode,
    ...toRefs(state)
  }
}
