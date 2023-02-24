import { ref, reactive, toRef } from 'vue'
import {
  BiologicalAssociation,
  BiologicalAssociationGraph,
  CollectionObject,
  Otu
} from 'routes/endpoints'

const extend = [
  'biological_associations_biological_associations_graphs',
  'biological_associations'
]

export function useGraph() {
  const state = reactive({
    nodes: {},
    edges: {},
    layouts: {},
    settings: {
      isSaving: false
    },
    graph: {
      biological_association_id: []
    }
  })

  function getNodes() {
    return state.nodeObjects.map((obj) => [
      obj.id,
      {
        name: obj.object_label
      }
    ])
  }

  function getEdges() {
    return state.biologicalRelations.map((ba) => [
      ba.uuid,
      { source: ba.subject, target: ba.object, label: ba.relation.object_label }
    ])
  }

  function resetStore() {
    Object.assign(state, {
      nodes: {},
      edges: {},
      layouts: {}
    })
  }

  return {
    resetStore,
    getNodes,
    ...toRef(state)
  }
}
