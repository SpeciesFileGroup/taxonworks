import { defineStore } from 'pinia'
import {
  COLLECTING_EVENT,
  DEPICTION,
  LABEL,
  IDENTIFIER
} from '@/constants/index.js'
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
import useSoftValidationStore from './softValidations.js'

const EXCLUDE_SOFT_VALIDATIONS = [LABEL, DEPICTION, IDENTIFIER]

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

function getGlobalIdFromResponse(responses) {
  return responses
    .flat()
    .map((r) => r.body)
    .flat()
    .filter((item) => !EXCLUDE_SOFT_VALIDATIONS.includes(item.base_class))
    .map((item) => item.global_id)
}

function parseCEResponse(ce) {
  const { collector_roles = [], ...rest } = ce

  return {
    ...rest,
    roles_attributes: collector_roles,
    isUnsaved: false
  }
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
      const softValidationStore = useSoftValidationStore()

      this.$reset()
      depictionStore.reset()
      identifierStore.$reset()
      georeferenceStore.$reset()
      softValidationStore.$reset()
      labelStore.$reset()
    },

    async save() {
      const georeferenceStore = useGeoreferenceStore()
      const idStore = useIdentifierStore()
      const depictionStore = useDepictionStore()
      const labelStore = useLabelStore()
      const softValidationStore = useSoftValidationStore()
      const cePayload = makeCollectingEventPayload(this.collectingEvent)

      try {
        const response = this.collectingEvent.id
          ? await CollectingEvent.update(this.collectingEvent.id, cePayload)
          : await CollectingEvent.create(cePayload)

        const { id } = response.body
        const payload = { objectId: id, objectType: COLLECTING_EVENT }

        this.collectingEvent = parseCEResponse(response.body)

        const promises = [
          response,
          georeferenceStore.save(id),
          depictionStore.save(payload)
        ]

        if (idStore.isUnsaved) {
          promises.push(idStore.save(payload))
        }

        if (labelStore.label.isUnsaved) {
          promises.push(labelStore.save(payload))
        }

        const responses = await Promise.all(promises)
        const globalIds = getGlobalIdFromResponse(responses)

        softValidationStore.load(globalIds)

        return responses
      } catch (e) {
        throw e
      }
    },

    async load(ceId) {
      const idStore = useIdentifierStore()
      const georeferenceStore = useGeoreferenceStore()
      const depictionStore = useDepictionStore()
      const labelStore = useLabelStore()
      const softValidationStore = useSoftValidationStore()

      this.reset()

      try {
        const response = await CollectingEvent.find(ceId, { extend: EXTEND })
        const payload = { objectId: ceId, objectType: COLLECTING_EVENT }
        const { id } = response.body

        this.collectingEvent = parseCEResponse(response.body)
        this.totalUsed = await getTotalUsed(id)

        const promises = [
          response,
          idStore.load(payload),
          georeferenceStore.load(ceId),
          depictionStore.load(payload),
          labelStore.load(payload)
        ]

        const responses = await Promise.all(promises)
        const globalIds = getGlobalIdFromResponse(responses)

        softValidationStore.load(globalIds)

        return responses
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
