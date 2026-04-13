import { defineStore } from 'pinia'
import { TaxonDetermination } from '@/routes/endpoints'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'

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
      return TaxonDetermination.where({
        taxon_determination_object_id: [objectId],
        taxon_determination_object_type: [objectType]
      }).then(({ body }) => {
        this.determinations = body.map((item) => ({
          ...item,
          uuid: randomUUID(),
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
          .then(() => {
            TW.workbench.alert.create(
              'Taxon determination was successfully destroyed.',
              'notice'
            )
          })
          .catch(() => {})
      }

      removeFromArray(this.determinations, determination, { property: 'uuid' })
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
    },

    reset({ keepRecords }) {
      if (keepRecords) {
        this.determinations.forEach((item) => {
          Object.assign(item, {
            id: null,
            isUnsaved: true
          })
        })
      } else {
        this.$reset()
      }
    }
  }
})
