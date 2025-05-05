import { Conveyance } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('conveyances', {
  state: () => ({
    conveyances: []
  }),

  actions: {
    async load({ objectId, objectType }) {
      return Conveyance.where({
        conveyance_object_id: objectId,
        conveyance_object_type: objectType,
        per: 100
      })
        .then(({ body }) => {
          this.conveyances = body
        })
        .catch(() => {})
    }
  }
})
