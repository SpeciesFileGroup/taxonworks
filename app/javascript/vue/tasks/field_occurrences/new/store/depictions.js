import { defineStore } from 'pinia'
import { Depiction } from '@/routes/endpoints'
import { removeFromArray, randomUUID } from '@/helpers'

export default defineStore('depictions', {
  state: () => ({
    depictions: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.depictions.some((c) => c.isUnsaved || c._destroy)
    }
  },

  actions: {
    load({ objectId, objectType }) {
      return Depiction.where({
        depiction_object_id: objectId,
        depiction_object_type: objectType,
        per: 100
      }).then(({ body }) => {
        this.depictions = body.map((c) => ({
          ...c,
          uuid: randomUUID(),
          isUnsaved: false
        }))
      })
    },

    remove(item) {
      if (item.id) {
        Depiction.destroy(item.id)
          .then(() => {
            TW.workbench.alert.create(
              'Depiction was successfully deleted.',
              'notice'
            )
          })
          .catch({})
      }

      removeFromArray(this.depictions, item, { property: 'uuid' })
    }
  }
})
