import { defineStore } from 'pinia'
import { BiologicalAssociation } from 'routes/endpoints'
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
    currentNodeType: null,
    currentNode: null,
    currentEvent: null,
    currentEdge: [],
    currentSVGCursorPosition: undefined,
    selectedNodes: [],
    selectedEdge: [],
    nextEdgeIndex: 0,
    nextNodeIndex: 0
  }),

  getters: {
    getNodes(state) {
      return state.nodes
    },

    getEdges(state) {
      return state.edges
    },

    getCreatedAssociationsByNodeId(state) {
      return (nodeId) =>
        Object.values(state.edges)
          .filter(
            (edge) =>
              edge.id && (nodeId === edge.source || nodeId === edge.target)
          )
          .map((edge) => edge.id)
    }
  },

  actions: {
    createNode(obj) {
      const nodeId = obj.id
      const name = obj.object_label

      this.layouts.nodes[nodeId] = this.currentSVGCursorPosition
      this.nodes[nodeId] = { obj, name }

      this.nextNodeIndex++
    },

    removeEdge(edgeId) {
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
          delete this.edges[key]
        }
      }
    },

    createEdge({ source, target, relationship }) {
      this.edges[this.nextEdgeIndex] = {
        source,
        target,
        label: relationship.name,
        relationship
      }

      this.nextEdgeIndex++
    },

    reverseRelation(edgeId) {
      const edge = this.edges[edgeId]

      this.edges[edgeId] = {
        ...edge,
        source: edge.target,
        target: edge.source
      }
    },

    createBiologicalAssociation() {
      const relations = Object.values(this.edges).filter((edge) => !edge.id)

      const requests = relations.map((relation) => {
        const subject = this.nodes[relation.source].obj
        const object = this.nodes[relation.target].obj

        const payload = {
          biological_relationship_id: relation.relationship.id,
          biological_association_object_id: object.id,
          biological_association_object_type: object.base_class,
          biological_association_subject_id: subject.id,
          biological_association_subject_type: subject.base_class
        }

        return BiologicalAssociation.create({
          biological_association: payload
        }).then(({ body }) => {
          relation.id = body.id
        })
      })

      return requests
    }
  }
})
