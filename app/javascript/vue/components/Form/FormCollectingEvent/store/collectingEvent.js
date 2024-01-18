import { defineStore } from 'pinia'
import {
  IDENTIFIER_LOCAL_TRIP_CODE,
  COLLECTING_EVENT
} from '@/constants/index.js'
import {
  GeographicArea,
  CollectingEvent,
  CollectionObject
} from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { getPagination } from '@/helpers'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeIdentifier from '@/factory/Identifier.js'
import makeLabel from '@/factory/Label'
import SetParam from '@/helpers/setParam'
import useGeoreferenceStore from './georeferences.js'

async function getTotalUsed(ceId) {
  const response = await CollectionObject.where({
    collecting_event_id: [ceId],
    per: 1
  })
  const pagination = getPagination(response)

  return pagination.total
}

const EXTEND = ['roles']

export default defineStore('collectingEventForm', {
  state: () => ({
    collectingEvent: makeCollectingEvent(),
    geographicArea: undefined,
    tripCode: makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, COLLECTING_EVENT),
    label: makeLabel(COLLECTING_EVENT),
    unit: 'm',
    totalUsed: 0
  }),

  actions: {
    reset() {
      const georeferenceStore = useGeoreferenceStore()

      this.$reset()
      georeferenceStore.$reset()
    },

    async save() {
      const store = useGeoreferenceStore()
      const payload = {
        collecting_event: {
          ...this.collectingEvent
        }
      }

      const { body } = this.collectingEvent.id
        ? await CollectingEvent.update(this.collectingEvent.id, payload)
        : await CollectingEvent.create(payload)

      store.processGeoreferenceQueue(body.id)
      this.collectingEvent.id = body.id

      return body
    },

    async load(ceId) {
      return CollectingEvent.find(ceId, { extend: EXTEND }).then(
        async ({ body }) => {
          body.roles_attributes = body.collector_roles || []
          this.collectingEvent = body

          this.totalUsed = await getTotalUsed(body.id)

          SetParam(
            RouteNames.NewCollectingEvent,
            'collecting_event_id',
            body.id
          )
        }
      )
    },

    async clone() {
      return CollectingEvent.clone(this.collectingEvent.id, {
        extend: EXTEND
      }).then(({ body }) => {
        this.load(body.id)
        TW.workbench.alert.create(
          'Collecting event was successfully cloned.',
          'notice'
        )
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
