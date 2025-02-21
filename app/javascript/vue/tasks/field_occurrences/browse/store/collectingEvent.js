import {
  CollectingEvent,
  GeographicArea,
  Georeference
} from '@/routes/endpoints'
import { defineStore } from 'pinia'

export default defineStore('collectingEvent', {
  state: () => ({
    collectingEvent: null,
    geographicArea: null,
    georeferences: []
  }),

  actions: {
    async load(collectingEventId) {
      try {
        CollectingEvent.find(collectingEventId).then(({ body }) => {
          this.collectingEvent = body

          if (body.geographic_area_id) {
            GeographicArea.find(body.geographic_area_id, {
              embed: ['shape']
            }).then(({ body }) => {
              this.geographicArea = body
            })
          }
        })

        Georeference.where({ collecting_event_id: collectingEventId }).then(
          ({ body }) => {
            this.georeferences = body
          }
        )
      } catch {}
    },

    async update(payload) {
      return CollectingEvent.update(this.collectingEvent.id, {
        collecting_event: payload
      })
        .then(({ body }) => {
          this.collectingEvent = body
        })
        .catch(() => {})
    }
  }
})
