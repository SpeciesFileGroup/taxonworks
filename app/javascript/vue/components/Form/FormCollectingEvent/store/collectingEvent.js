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
import useDepictionStore from './depictions.js'

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
      const georeferencesStore = useGeoreferenceStore()
      const depictionStore = useDepictionStore()

      return (
        state.collectingEvent.isUnsaved ||
        idStore.identifier.isUnsaved ||
        georeferencesStore.hasUnsaved ||
        depictionStore.hasUnsaved
      )
    }
  },

  actions: {
    reset() {
      const georeferenceStore = useGeoreferenceStore()
      const identifierStore = useIdentifierStore()
      const depictionStore = useDepictionStore()

      this.$reset()
      depictionStore.reset()
      identifierStore.$reset()
      georeferenceStore.$reset()
    },

    async save() {
      const store = useGeoreferenceStore()
      const idStore = useIdentifierStore()
      const depictionStore = useDepictionStore()
      const payload = {
        collecting_event: {
          ...this.collectingEvent
        },
        extend: EXTEND
      }

      const request = this.collectingEvent.id
        ? CollectingEvent.update(this.collectingEvent.id, payload)
        : CollectingEvent.create(payload)

      request.then(({ body }) => {
        const payload = { objectId: body.id, objectType: COLLECTING_EVENT }

        store.processGeoreferenceQueue(body.id)
        this.collectingEvent.id = body.id
        this.collectingEvent.global_id = body.global_id
        this.collectingEvent.roles_attributes = body.collector_roles || []

        depictionStore.save(payload)

        if (idStore.isUnsaved) {
          idStore.save(payload)
        }
      })

      return request
    },

    async load(ceId) {
      const idStore = useIdentifierStore()
      const georeferenceStore = useGeoreferenceStore()
      const depictionStore = useDepictionStore()

      this.reset()

      try {
        const { body } = await CollectingEvent.find(ceId, { extend: EXTEND })
        const payload = { objectId: ceId, objectType: COLLECTING_EVENT }

        body.roles_attributes = body.collector_roles || []

        this.collectingEvent = body
        this.totalUsed = await getTotalUsed(body.id)

        await idStore.load(payload)
        await georeferenceStore.load(ceId)
        await depictionStore.load(payload)

        return body
      } catch (e) {}
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
