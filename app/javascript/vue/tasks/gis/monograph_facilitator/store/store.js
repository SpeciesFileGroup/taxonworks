import { defineStore } from 'pinia'
import { Georeference } from '@/routes/endpoints'
import { getUnique, randomHue, randomUUID } from '@/helpers'
import { makeMarkerStyle } from '../utils'
import { addToArray, removeFromArray } from '@/helpers'
import { toRaw } from 'vue'
import { QUERY_PARAMETER } from '@/tasks/data_attributes/field_synchronize/constants'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import store from '@/tasks/citations/otus/store/store'

const extend = ['taxon_determinations']

function makeDetermination(d = {}) {
  return {
    id: d.id,
    otuId: d.otu_id,
    label: d.id ? d.object_tag : '<i>Without determinations</i>'
  }
}

function makeObject(o) {
  return {
    globalId: o.global_id,
    id: o.id,
    type: o.base_class,
    collectingEventId: o.collecting_event_id,
    label: o.object_label,
    determination: makeDetermination(o.taxon_determinations?.[0])
  }
}

function buildGroups(objects) {
  const determinations = getUnique(
    objects.map((o) => o.determination),
    'otuId'
  )

  return determinations.map((d, index) => ({
    uuid: randomUUID(),
    determination: d,
    color: randomHue(index),
    list: objects.filter((o) => o.determination?.otuId === d.otuId),
    isListVisible: false
  }))
}

export default defineStore('monographFacilitator', {
  state: () => ({
    isLoading: false,
    objectType: null,
    georeferences: [],
    determinations: [],
    objects: [],
    selectedIds: [],
    settings: {},
    groups: [],
    hiddenIds: [],
    hoverIds: [],
    clickedLayer: null
  }),

  getters: {
    objectIds(state) {
      return state.objects.map((o) => o.id)
    },

    getGeoreferenceByOtuId(state) {
      return (otuId) => {
        const objects = state.getVisibleObjects.filter(
          (o) => o.determination.otuId === otuId
        )
        const ceIds = objects.map((o) => o.collectingEventId)

        return state.georeferences.filter((g) =>
          ceIds.includes(g.collecting_event_id)
        )
      }
    },

    getGeoreferencesByObjectId(state) {
      return (id) => {
        const object = state.objects.find((o) => o.id === id)
        const ceId = object.collectingEventId

        return ceId
          ? state.georeferences.filter(
              (g) => g.collecting_event_id === object.collectingEventId
            )
          : []
      }
    },

    getVisibleObjects(state) {
      return state.objects.filter((o) => !state.hiddenIds.includes(o.id))
    },

    getObjectByGeoreferenceId(state) {
      return (id) => {
        const georeference = state.georeferences.find((g) => g.id === id)

        return state.objects.filter(
          (o) => o.collectingEventId === georeference.collecting_event_id
        )
      }
    },

    shapes(state) {
      return state.groups
        .map((group) => {
          const otuId = group.determination.otuId
          const features = state.getGeoreferenceByOtuId(otuId).map((g) => {
            const objects = state.getObjectByGeoreferenceId(g.id)
            const objectIds = objects.map((o) => o.id)
            const feature = structuredClone(toRaw(g.geo_json))

            const isSelected = objects.some((o) =>
              state.selectedIds.includes(o.id)
            )

            feature.properties.objectIds = objectIds
            feature.properties.style = makeMarkerStyle({
              color: group.color,
              isSelected
            })

            return feature
          })

          return features
        })
        .flat()
    }
  },

  actions: {
    async load() {
      const { queryValue, queryParam } = useQueryParam()
      const { service, model } = QUERY_PARAMETER[queryParam.value]

      this.objectType = model
      this.isLoading = true
      try {
        const { body } = await service.filter({ ...queryValue.value, extend })
        const ceId = body.map((c) => c.collecting_event_id)

        if (ceId.length) {
          const { body: georeferences } = await Georeference.all({
            collecting_event_id: ceId
          })

          if (georeferences.length) {
            this.georeferences = georeferences
          }
        }

        this.objects = body.map(makeObject)
        this.groups = buildGroups(this.objects)
      } catch (e) {
        throw e
      }

      this.isLoading = false
    },

    setObjectVisibilityById(id, visible) {
      if (visible) {
        addToArray(this.hiddenIds, id, { primitive: true })
      } else {
        removeFromArray(this.hiddenIds, id, { primitive: true })
      }
    },

    updateGroupByUUID(uuid, data) {
      const group = this.groups.find((g) => g.uuid == uuid)

      Object.assign(group, data)
    },

    invertSelection() {
      this.selectedIds = this.objectIds.filter(
        (id) => !this.selectedIds.includes(id)
      )
    }
  }
})
