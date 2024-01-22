import { defineStore } from 'pinia'
import { COLLECTING_EVENT } from '@/constants/index.js'
import {
  GeographicArea,
  CollectingEvent,
  CollectionObject
} from '@/routes/endpoints'
import { getPagination } from '@/helpers'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import makeLabel from '@/factory/Label'
import useGeoreferenceStore from './georeferences.js'
import useIdentifierStore from './identifier.js'

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
    label: makeLabel(COLLECTING_EVENT),
    unit: 'm',
    totalUsed: 0
  }),

  getters: {
    isUnsaved(state) {
      const idStore = useIdentifierStore()

      return state.collectingEvent.isUnsaved || idStore.identifier.isUnsaved
    }
  },

  actions: {
    reset() {
      const georeferenceStore = useGeoreferenceStore()

      this.$reset()
      georeferenceStore.$reset()
    },

    async save() {
      const store = useGeoreferenceStore()
      const idStore = useIdentifierStore()
      const payload = {
        collecting_event: {
          ...this.collectingEvent
        }
      }

      const request = this.collectingEvent.id
        ? CollectingEvent.update(this.collectingEvent.id, payload)
        : CollectingEvent.create(payload)

      request.then(({ body }) => {
        store.processGeoreferenceQueue(body.id)
        this.collectingEvent.id = body.id

        if (idStore.isUnsaved) {
          idStore.save({ objectId: body.id, objectType: COLLECTING_EVENT })
        }
      })

      return request
    },

    async load(ceId) {
      const idStore = useIdentifierStore()

      return CollectingEvent.find(ceId, { extend: EXTEND }).then(
        async ({ body }) => {
          body.roles_attributes = body.collector_roles || []

          this.collectingEvent = body
          this.totalUsed = await getTotalUsed(body.id)

          idStore.load({ objectId: ceId, objectType: COLLECTING_EVENT })
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
