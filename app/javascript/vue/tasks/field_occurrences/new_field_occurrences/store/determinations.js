import { defineStore } from 'pinia'
import { TaxonDetermination } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers'

export default defineStore('taxonDeterminations', {
  state: () => ({
    determinations: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.determinations.some(c => c.isUnsaved)
    }
  },

  actions: {
    loadDeterminations({ id, type }) {
      TaxonDetermination.where({
        taxon_determination_object_id: id,
        taxon_determination_object_type: type
      }).then(({ body }) => {
        this.determinations = body.map(item => 
          ({
            ...item, 
            uuid: crypto.randomUUID(), 
            isUnsaved: false
          })
        )
      })
    },

    addDetermination(determination) {
        addToArray(this.determinations, determination, {
          property: 'uuid',
          prepend: true
        })
    },

    removeDetermination(determination) {
      if (determination.id) {
        TaxonDetermination.destroy(determination.id)
      }

      removeFromArray(this.determinations, determination, 'uuid')
    }
  }
})
