import { AnatomicalPart } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('anatomicalParts', {
  state: () => ({
    anatomicalParts: []
  }),

  actions: {
    async load({ objectId, objectType }) {
      AnatomicalPart.childrenOf({
        parent_id: objectId,
        parent_type: objectType
      })
        .then(({ body }) => {
          this.anatomicalParts = body
        })
        .catch(() => {})
    }
  }
})