import { defineStore } from 'pinia'
import { COLLECTING_EVENT } from '@/constants/index.js'
import {
  GeographicArea,
  CollectingEvent,
  CollectionObject
} from '@/routes/endpoints'
import { getPagination } from '@/helpers'
import makeCollectingEvent from '@/factory/CollectingEvent.js'
import useGeoreferenceStore from './georeferences.js'
import useIdentifierStore from './identifier.js'
import useDepictionStore from './depictions.js'
import useLabelStore from './label.js'

const ELEVATION_ATTRS = [
  'minimum_elevation',
  'maximum_elevation',
  'elevation_precision'
]

const EXTEND = ['roles']

function feetsToMeters(feets) {
  return feets / 3.281
}

function parseEvelation(collectingEvent) {
  const elevation = {}

  ELEVATION_ATTRS.forEach((attr) => {
    const elevationValue = Number(collectingEvent[attr])

    if (elevationValue > 0) {
      elevation[attr] = feetsToMeters(elevationValue)
    }
  })

  return elevation
}

function makeCollectingEventPayload(collectingEvent) {
  const ce =
    collectingEvent.unit === 'ft'
      ? {
          ...collectingEvent,
          ...parseEvelation(collectingEvent)
        }
      : { ...collectingEvent }

  return {
    collecting_event: ce,
    extend: EXTEND
  }
}

async function getTotalUsed(ceId) {
  const response = await CollectionObject.where({
    collecting_event_id: [ceId],
    per: 1
  })
  const pagination = getPagination(response)

  return pagination.total
}

export default defineStore('collectingEventForm', {
  state: () => ({
    collectingEvent: makeCollectingEvent(),
    geographicArea: undefined,
    totalUsed: 0
  }),

  getters: {
    isUnsaved(state) {
      const idStore = useIdentifierStore()
      const georeferencesStore = useGeoreferenceStore()
      const depictionStore = useDepictionStore()
      const labelStore = useLabelStore()

      return (
        state.collectingEvent.isUnsaved ||
        idStore.identifier.isUnsaved ||
        labelStore.label.isUnsaved ||
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
      const labelStore = useLabelStore()

      this.$reset()
      depictionStore.reset()
      identifierStore.$reset()
      georeferenceStore.$reset()
      labelStore.$reset()
    },

    async save() {
      const georeferenceStore = useGeoreferenceStore()
      const idStore = useIdentifierStore()
      const depictionStore = useDepictionStore()
      const labelStore = useLabelStore()
      const cePayload = makeCollectingEventPayload(this.collectingEvent)

      try {
        const { body } = this.collectingEvent.id
          ? await CollectingEvent.update(this.collectingEvent.id, cePayload)
          : await CollectingEvent.create(cePayload)

        const { collector_roles = [], ...rest } = body
        const payload = { objectId: body.id, objectType: COLLECTING_EVENT }

        this.collectingEvent = {
          ...rest,
          roles_attributes: collector_roles,
          isUnsaved: false
        }

        const promises = [
          georeferenceStore.save(body.id),
          depictionStore.save(payload),
          labelStore.save(payload)
        ]

        if (idStore.isUnsaved) {
          promises.push(idStore.save(payload))
        }

        await Promise.all(promises)

        return body
      } catch (e) {
        throw e
      }
    },

    async load(ceId) {
      const idStore = useIdentifierStore()
      const georeferenceStore = useGeoreferenceStore()
      const depictionStore = useDepictionStore()
      const labelStore = useLabelStore()

      this.reset()

      try {
        const { body } = await CollectingEvent.find(ceId, { extend: EXTEND })
        const payload = { objectId: ceId, objectType: COLLECTING_EVENT }

        body.roles_attributes = body.collector_roles || []

        this.collectingEvent = { ...body, isUnsaved: false }
        this.totalUsed = await getTotalUsed(body.id)

        await idStore.load(payload)
        await georeferenceStore.load(ceId)
        await depictionStore.load(payload)
        await labelStore.load(payload)

        return body
      } catch (e) {
        throw e
      }
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
