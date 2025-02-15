import { Depiction } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('depictions', {
  state: () => ({
    depictions: []
  }),

  actions: {
    async load({ objectId, objectType }) {
      return Depiction.where({
        depiction_object_id: objectId,
        depiction_object_type: objectType,
        per: 100
      })
        .then(({ body }) => {
          this.depictions = body
        })
        .catch(() => {})
    }
  }
})
