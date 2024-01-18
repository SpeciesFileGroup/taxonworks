import { defineStore } from 'pinia'
import { Georeference } from '@/routes/endpoints'
import { addToArray } from '@/helpers'

export default defineStore('georeferences', {
  state: () => ({
    georeferences: [],
    queueGeoreferences: []
  }),

  actions: {
    load(ceId) {
      Georeference.where({ collecting_event_id: ceId }).then(({ body }) => {
        this.georeferences = body
      })
    },

    async processGeoreferenceQueue(ceId) {
      if (!ceId) return

      const requests = this.queueGeoreferences.map((item) => {
        const georeference = {
          ...item,
          collecting_event_id: ceId
        }

        const request = georeference.id
          ? Georeference.update(georeference.id, { georeference })
          : Georeference.create({ georeference })

        request
          .then(({ body }) => addToArray(this.georeferences, body))
          .catch((_) => {})

        return request
      })

      return Promise.allSettled(requests).then((_) => {
        this.queueGeoreferences = []
      })
    }
  }
})
