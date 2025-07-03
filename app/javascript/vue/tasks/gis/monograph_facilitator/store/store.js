import { defineStore } from 'pinia'
import { Georeference, CollectionObject } from '@/routes/endpoints'
import { getUnique, randomHue } from '@/helpers'
import { makeMarkerStyle } from '../utils'
import { toRaw } from 'vue'

const extend = ['taxon_determinations']

function makeDetermination(d = {}) {
  return {
    id: d.id,
    otuId: d.otu_id,
    label: d.object_tag
  }
}

function makeObject(o) {
  return {
    objectId: o.id,
    objectType: o.type,
    collectingEventId: o.collecting_event_id,
    label: o.object_tag,
    determination: makeDetermination(o.taxon_determinations?.[0])
  }
}

function buildGroups(objects) {
  const determinations = getUnique(
    objects.map((o) => o.determination).filter((d) => d.otuId),
    'otuId'
  )

  return determinations.map((d, index) => ({
    determination: d,
    color: randomHue(index),
    list: objects.filter((o) => o.determination?.otuId === d.otuId),
    visible: true
  }))
}

export default defineStore('monographFacilitator', {
  state: () => ({
    isLoading: false,
    georeferences: [],
    determinations: [],
    objects: [],
    selectedIds: [],
    settings: {},
    groups: []
  }),

  getters: {
    getGeoreferenceByOtuId(state) {
      return (otuId) => {
        const objects = state.objects.filter(
          (o) => o.determination.otuId === otuId
        )
        const ceIds = objects.map((o) => o.collectingEventId)

        return state.georeferences.filter((g) =>
          ceIds.includes(g.collecting_event_id)
        )
      }
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
        .filter((group) => group.visible)
        .map((group) => {
          const otuId = group.determination.otuId
          const features = state.getGeoreferenceByOtuId(otuId).map((g) => {
            const objects = state.getObjectByGeoreferenceId(g.id)
            const feature = g.geo_json

            const isSelected = objects.some((o) =>
              state.selectedIds.includes(o.objectId)
            )

            feature.properties.style = makeMarkerStyle({
              color: group.color,
              isSelected
            })

            return toRaw(feature)
          })

          return features
        })
        .flat()
    }
  },

  actions: {
    async load(params) {
      this.isLoading = true
      try {
        const { body } = await CollectionObject.filter({ ...params, extend })
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
    }
  }
})
