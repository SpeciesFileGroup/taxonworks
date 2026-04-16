import { TaxonDetermination } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('determinations', {
  state: () => ({
    determinations: []
  }),

  actions: {
    async load({ objectId, objectType }) {
      return TaxonDetermination.where({
        taxon_determination_object_id: [objectId],
        taxon_determination_object_type: [objectType]
      })
        .then(({ body }) => {
          this.determinations = body
        })
        .catch(() => {})
    }
  }
})
