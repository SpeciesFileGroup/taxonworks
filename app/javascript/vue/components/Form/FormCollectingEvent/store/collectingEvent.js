import { defineStore } from 'pinia'
import { IDENTIFIER_LOCAL_TRIP_CODE } from '@/constants/index.js'
import { Georeference, GeographicArea } from '@/routes/endpoints'
import { addToArray } from '@/helpers'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeIdentifier from '@/factory/Identifier.js'
import makeLabel from '@/factory/Label'

export default defineStore('collectingEventForm', {
  state: () => ({
    collectingEvent: makeCollectingEvent(),
    geographicArea: undefined,
    georeferences: [],
    tripCode: makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, 'CollectingEvent'),
    queueGeoreferences: [],
    label: makeLabel('CollectingEvent'),
    unit: 'm'
  }),

  actions: {
    async processGeoreferenceQueue() {
      if (!this.collectingEvent.id) return

      const requests = this.queueGeoreferences.map((item) => {
        const georeference = {
          ...item,
          collecting_event_id: this.collectingEvent.id
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
    },

    async loadGeographicArea(id = null) {
      const geographicArea = id
        ? (await GeographicArea.find(id, { embed: ['shape'] })).body
        : null

      if (this.collectingEvent.geographic_area_id !== geographicArea?.id) {
        this.collectingEvent.geographic_area_id = id
      }

      if (!id) {
        this.collectingEvent.meta_prioritize_geographic_area = null
      }

      this.geographicArea = geographicArea
    }
  }
})
