import { defineStore } from 'pinia'
import { TaxonDetermination } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers'

export default defineStore('taxonDeterminations', {
  state: () => ({
    determinations: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.determinations.some((c) => c.isUnsaved)
    }
  },

  actions: {
    load({ objectId, objectType }) {
      TaxonDetermination.where({
        taxon_determination_object_id: [objectId],
        taxon_determination_object_type: [objectType]
      }).then(({ body }) => {
        this.determinations = body.map((item) => ({
          ...item,
          uuid: crypto.randomUUID(),
          isUnsaved: false
        }))
      })
    },

    add(determination) {
      addToArray(
        this.determinations,
        { ...determination, isUnsaved: true },
        {
          property: 'uuid',
          prepend: true
        }
      )
    },

    remove(determination) {
      if (determination.id) {
        TaxonDetermination.destroy(determination.id)
      }

      removeFromArray(this.determinations, determination, 'uuid')
    },

    save({ objectId, objectType }) {
      const determinations = this.determinations.filter((d) => d.isUnsaved)

      const requests = determinations.map((determination) => {
        const payload = {
          taxon_determination: {
            determination,
            taxon_determination_object_id: objectId,
            taxon_determination_object_type: objectType
          }
        }

        const request = determination.id
          ? TaxonDetermination.update(determination.id, payload)
          : TaxonDetermination.create(determination)

        request.then(({ body }) => {
          body.uuid = determination.uuid
          addToArray(this.determinations, body, { property: 'uuid' })
        })

        return request
      })

      return Promise.all(requests)
    }
  }
})
