import { defineStore } from 'pinia'
import { Georeference } from '@/routes/endpoints'
import { addToArray, removeFromArray, randomUUID } from '@/helpers'
import {
  GEOREFERENCE,
  GEOREFERENCE_GEOLOCATE,
  GEOREFERENCE_WKT,
  GEOREFERENCE_VERBATIM
} from '@/constants'

export default defineStore('collectingEventForm:georeferences', {
  state: () => ({
    georeferences: [],
    exifGeoreferences: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.georeferences.some((item) => item.isUnsaved)
    },

    geojson(state) {
      const EXCLUDE = [GEOREFERENCE_GEOLOCATE, GEOREFERENCE_WKT]
      const { georeferences } = state

      const parsed = georeferences
        .filter(
          (item) =>
            (item.id || !EXCLUDE.includes(item.type)) &&
            (item.geographic_item_attributes?.shape || item.geo_json)
        )
        .map((item) => {
          const geojson = item.geographic_item_attributes
            ? JSON.parse(item?.geographic_item_attributes.shape)
            : { ...item.geo_json }

          geojson.properties = {
            uuid: item.uuid,
            base: [
              {
                type: [GEOREFERENCE]
              }
            ],
            ...(item.type === GEOREFERENCE_VERBATIM && {
              style: { className: 'map-point-marker bg-verbatim' }
            })
          }

          return geojson
        })

      return [...parsed]
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
