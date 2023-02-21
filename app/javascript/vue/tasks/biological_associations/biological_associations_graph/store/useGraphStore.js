import { defineStore } from 'pinia'

export const useGraphStore = defineStore('useGraphStore', {
  state: () => ({
    nodes: {},
    edges: {},
    layouts: {
      nodes: {}
    },
    currentNode: null,
    currentEvent: null,
    currentEdge: null,
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
    }
  }
})
