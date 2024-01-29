import { defineStore } from 'pinia'
import { Georeference } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers'

export default defineStore('georeferences', {
  state: () => ({
    georeferences: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.georeferences.some((item) => item.isUnsaved)
    }
  },

  actions: {
    async load(ceId) {
      try {
        const { body } = await Georeference.where({ collecting_event_id: ceId })

        this.georeferences = body.map((item) => ({
          ...item,
          uuid: crypto.randomUUID(),
          isUnsaved: false
        }))

        return body
      } catch (e) {}
    },

    async remove(georeference) {
      if (georeference.id) {
        Georeference.destroy(georeference.id)
      }

      removeFromArray(this.georeferences, georeference, 'uuid')
    },

    async processGeoreferenceQueue(ceId) {
      if (!ceId) return

      const unsaved = this.georeferences.filter((item) => item.isUnsaved)
      const requests = unsaved.map((item) => {
        const georeference = {
          ...item,
          collecting_event_id: ceId
        }

        const request = georeference.id
          ? Georeference.update(georeference.id, { georeference })
          : Georeference.create({ georeference })

        request
          .then(({ body }) =>
            addToArray(this.georeferences, Object.assign(item, body))
          )
          .catch((_) => {})

        return request
      })

      return Promise.allSettled(requests).then((_) => {
        this.georeferences = []
      })
    }
  }
})
