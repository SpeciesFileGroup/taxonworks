import { defineStore } from 'pinia'
import { Lead } from '@/routes/endpoints'

export default defineStore('dichotomous', {
  state: () => ({
    lead: undefined,
    children: [],
    lead_item_otus: [],
    key_metadata: undefined,
    key_ordered_parents: [],
    key_depictions: [],
    remaining: [],
    eliminated: []
  }),

  getters: {
    keyTree(state) {
      if (
        !state.key_metadata ||
        !state.key_data ||
        !state.key_ordered_parents
      ) {
        return null
      }

      const nodesById = {}

      state.key_ordered_parents.forEach((parentId) => {
        const meta = state.key_metadata[parentId]

        nodesById[parentId] = {
          id: parentId,
          coupletNumber: meta.couplet_number,
          depth: meta.depth,
          backLink: state.key_data.back_couplets?.[meta.couplet_number],
          children: [],
          _childIds: meta.children
        }
      })

      Object.values(nodesById).forEach((node) => {
        node.children = node._childIds.map((childId) => {
          const data = state.key_data[childId]
          const depictions = state.key_depictions[childId]
          const isFirstLine = data.position === 0

          let linkType = null
          if (!data.target_label) {
            linkType =
              data.target_type === 'lead_item_otus' ? 'lead_item_otus' : null
          } else if (data.target_type === 'internal') {
            linkType = 'couplet'
          } else if (data.target_type === 'lead_item_otus') {
            linkType = 'lead_item_otus'
          } else {
            linkType = 'otu'
          }

          return {
            id: childId,
            parentId: node.id,
            position: data.position,
            depictions,
            isFirstLine,
            text: data.text || '<no text>',
            coupletNumber: node.coupletNumber,
            beginLabel: isFirstLine
              ? node.coupletNumber
              : '.'.repeat(7 + node.coupletNumber.toString().length),
            linkType,
            targetId: data.target_id,
            targetLabel: data.target_label,
            leadItemOtus: data.lead_item_otus || [],
            hasMultipleOtus: data.lead_item_otus?.length > 1,
            hasSingleOtuWithoutTarget:
              data.lead_item_otus?.length === 1 && !data.target_id
          }
        })
      })

      Object.values(nodesById).forEach((node) => {
        node.children.forEach((child) => {
          if (child.linkType === 'couplet') {
            const targetNode = Object.values(nodesById).find(
              (n) => n.coupletNumber === child.targetLabel
            )
            if (targetNode) {
              child.nextCouplet = targetNode
            }
          }
        })
      })

      return Object.values(nodesById).find((n) => n.depth === 1)
    }
  },

  actions: {
    async loadKey(id) {
      try {
        const [leadResponse, remaningResponse, eliminatedResponse] =
          await Promise.all([
            Lead.find(id, {
              extend: ['key_data', 'key_depictions']
            }),

            Lead.remainingOtus(id),
            Lead.eliminatedOtus(id)
          ])

        leadResponse.body

        this.root = leadResponse.body.root
        this.lead = leadResponse.body.lead
        this.children = leadResponse.body.children
        this.lead_item_otus = leadResponse.body.lead_item_otus

        this.key_metadata = leadResponse.body.key_metadata
        this.key_ordered_parents = leadResponse.body.key_ordered_parents
        this.key_data = leadResponse.body.key_data
        this.key_depictions = leadResponse.body.key_depictions

        this.remaining = remaningResponse.body
        this.eliminated = eliminatedResponse.body
      } catch {}
    }
  }
})
