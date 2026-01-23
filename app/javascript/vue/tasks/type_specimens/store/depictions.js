import { COLLECTION_OBJECT } from '@/constants'
import { Depiction } from '@/routes/endpoints'
import { defineStore } from 'pinia'
import { removeFromArray } from '@/helpers'

export default defineStore('depictions', {
  state: () => ({
    depictions: []
  }),

  actions: {
    load(coId) {
      Depiction.where({
        depiction_object_id: coId,
        depiction_object_type: COLLECTION_OBJECT
      }).then(({ body }) => {
        this.depictions = body
      })
    },

    destroy(depiction) {
      Depiction.destroy(depiction.id).then(() => {
        removeFromArray(this.depictions, depiction)
      })
    }
  }
})
