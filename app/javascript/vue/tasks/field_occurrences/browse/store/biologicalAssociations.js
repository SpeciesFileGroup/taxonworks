import { BiologicalAssociation } from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('biologicalAssociations', {
  state: () => ({
    biologicalAssociations: []
  }),

  actions: {
    async load({ objectId, objectType }) {
      return BiologicalAssociation.where({
        biological_association_subject_id: [objectId],
        biological_association_subject_type: [objectType]
      })
        .then(({ body }) => {
          this.biologicalAssociations = body
        })
        .catch(() => {})
    }
  }
})
