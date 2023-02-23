import { defineStore } from 'pinia'
import {
  BiologicalAssociation,
  BiologicalAssociationGraph
} from 'routes/endpoints'

const extend = [
  'biological_associations_biological_associations_graphs',
  'biological_associations'
]

export const useGraphStore = defineStore('useGraphStore', {
  state: () => ({
    nodes: {},
    edges: {},
    layouts: {
      nodes: {}
    },
    modal: {
      node: false,
      edge: false
    },
    relations: [],
    currentNodeType: null,
    currentNode: null,
    currentEvent: null,
    currentEdge: [],
    currentSVGCursorPosition: undefined,
    selectedNodes: [],
    selectedEdge: [],
    nextEdgeIndex: 0,
    nextNodeIndex: 0,
    settings: {
      isSaving: false
    },
    graph: {
      biological_association_id: []
    }
  }),

  getters: {
    getNodes(state) {
      return state.nodes
    },

    getEdges(state) {
      return state.edges
    },

    isUnsaved(state) {
      return Object.values(state.edges).some((edge) => edge.isUnsaved)
    },

    getCreatedAssociationsByNodeId(state) {
      return (nodeId) =>
        Object.values(state.edges)
          .filter(
            (edge) =>
              edge.id && (nodeId === edge.source || nodeId === edge.target)
          )
          .map((edge) => edge.id)
    },

    isNetwork(state) {
      const edges = Object.values(state.edges)
      const sources = edges.map((edge) => edge.source)
      const targets = edges.map((edge) => edge.target)
      const uniqueTargets = [...new Set(targets)]
      const uniqueSources = [...new Set(sources)]

      return (
        sources.some((nodeId) => targets.includes(nodeId)) ||
        uniqueSources.length < sources.length ||
        uniqueTargets.length < targets.length
      )
    }
  },

  actions: {
    createNode(obj) {
      const nodeId = obj.id
      const name = obj.object_label
      const isUnsaved = obj.isUnsaved

      this.nodes[nodeId] = { obj, name, isUnsaved }

      this.nextNodeIndex++
    },

    setNodePosition(nodeId, position) {
      this.layouts.nodes[nodeId] = position
    },

    removeEdge(edgeId) {
      const baId = this.edges[edgeId].id

      BiologicalAssociation.destroy(baId)

      delete this.edges[edgeId]
    },

    removeNode(nodeId) {
      const biologicalAssociationsCreated =
        this.getCreatedAssociationsByNodeId(nodeId)

      biologicalAssociationsCreated.forEach((id) =>
        BiologicalAssociation.destroy(id)
      )

      delete this.nodes[nodeId]

      for (const key in this.edges) {
        const target = this.edges[key].target
        const source = this.edges[key].source

        if (!this.nodes[target] || !this.nodes[source]) {
          this.removeEdge(key)
        }
      }
    },

    createEdge({ source, target, relationship, id, isUnsaved }) {
      this.edges[this.nextEdgeIndex] = {
        id,
        source,
        target,
        label: relationship.name,
        relationship,
        isUnsaved
      }

      this.graph.isUnsaved = true
      this.nextEdgeIndex++
    },

    reverseRelation(edgeId) {
      const edge = this.edges[edgeId]

      this.edges[edgeId] = {
        ...edge,
        source: edge.target,
        target: edge.source,
        isUnsaved: true
      }
    },

    async loadGraph(graphId) {
      const { body: graph } = await BiologicalAssociationGraph.find(graphId, {
        extend
      })
      const baIds =
        graph.biological_associations_biological_associations_graphs.map(
          (ba) => ba.biological_association_id
        )

      this.graph = graph

      return BiologicalAssociation.where({
        biological_association_id: baIds,
        extend: ['subject', 'object', 'biological_relationship']
      }).then(({ body }) => {
        body.forEach((ba) => {
          this.createNode(ba.subject)
          this.createNode(ba.object)
          this.createEdge({
            id: ba.id,
            source: ba.subject.id,
            target: ba.object.id,
            relationship: {
              ...ba.biological_relationship,
              id: ba.biological_relationship_id,
              name: ba.biological_relationship.object_label
            }
          })
        })
      })
    },

    saveBiologicalAssociations() {
      const relations = Object.values(this.edges).filter(
        (edge) => edge.isUnsaved
      )

      const requests = relations.map((relation) => {
        const subject = this.nodes[relation.source].obj
        const object = this.nodes[relation.target].obj

        const payload = {
          biological_association: {
            biological_relationship_id: relation.relationship.id,
            biological_association_object_id: object.id,
            biological_association_object_type: object.base_class,
            biological_association_subject_id: subject.id,
            biological_association_subject_type: subject.base_class
          }
        }

        const request = relation.id
          ? BiologicalAssociation.update(relation.id, payload)
          : BiologicalAssociation.create(payload)

        request.then(({ body }) => {
          relation.id = body.id
          relation.isUnsaved = false
        })

        return request
      })

      Promise.all(requests).then(async (_) => {
        if (this.isNetwork) {
          const savedAssociations = Object.values(this.edges).filter(
            (r) => r.id
          )
          const graphAssociations = (
            this.graph.biological_associations_biological_associations_graphs ||
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

          const request = this.graph.id
            ? BiologicalAssociationGraph.update(this.graph.id, payload)
            : BiologicalAssociationGraph.create(payload)

          this.graph = (await request).body
        }
      })

      return requests
    }
  }
})
