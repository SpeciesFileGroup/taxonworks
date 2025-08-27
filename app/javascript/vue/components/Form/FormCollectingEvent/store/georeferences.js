import { defineStore } from 'pinia'
import { Georeference } from '@/routes/endpoints'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'

export default defineStore('collectingEventForm:georeferences', {
  state: () => ({
    georeferences: [],
    exifGeoreferences: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.georeferences.some((item) => item.isUnsaved)
    }
  },

  actions: {
    async load(ceId) {
      const request = Georeference.where({ collecting_event_id: ceId })

      request.then(({ body }) => {
        this.georeferences = body.map((item) => ({
          ...item,
          uuid: randomUUID(),
          isUnsaved: false
        }))
      })

      return request
    },

    async remove(georeference) {
      if (georeference.id) {
        Georeference.destroy(georeference.id)
      }

      removeFromArray(this.georeferences, georeference, { property: 'uuid' })
    },

    async save(ceId) {
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
            addToArray(
              this.georeferences,
              {
                ...body,
                uuid: item.uuid,
                isUnsaved: false
              },
              {
                property: 'uuid'
              }
            )
          )
          .catch((_) => {})

        return request
      })

      return Promise.all(requests)
    }
  }
})
