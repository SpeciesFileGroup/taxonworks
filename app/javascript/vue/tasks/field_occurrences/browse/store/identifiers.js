import { Identifier } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('identifiers', {
  state: () => ({
    identifiers: []
  }),

  actions: {
    async load({ objectId, objectType }) {
      return Identifier.where({
        identifier_object_id: [objectId],
        identifier_object_type: [objectType]
      })
        .then(({ body }) => {
          this.identifiers.push(...body)
        })
        .catch(() => {})
    }
  }
})
