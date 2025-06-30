import { defineStore } from 'pinia'
import { Georeference, CollectionObject } from '@/routes/endpoints'
import { getUnique, randomHue } from '@/helpers'

const extend = ['taxon_determinations']

function makeDetermination(d = {}) {
  return {
    id: d.id,
    otuId: d.otu_id,
    label: d.object_tag
  }
}

function makeMarkerStyle(color) {
  return {
    className: '',
    iconSize: [8, 8],
    iconAnchor: [4, 4],
    html: `<div class="map-point-marker" style="width: 8px; height: 8px; background-color: ${color}"></div>`
  }
}

function makeFeatureProperties(feature, color) {
  feature.properties.style = makeMarkerStyle(color)

  return feature
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

export default defineStore('monographFacilitator', {
  state: () => ({
    isLoading: false,
    georeferences: [],
    determinations: [],
    objects: [],
    selectedIds: [],
    settings: {}
  }),

  getters: {
    getGeoreferenceOtuId(state) {
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
          (o) => o.collectingEventId === georeference.id
        )
      }
    },

    shapes(state) {
      return state.groups
        .map((group) => {
          const otuId = group.determination.otuId
          const features = state
            .getGeoreferenceOtuId(otuId)
            .map((g) => makeFeatureProperties(g.geo_json, group.color))

          return features
        })
        .flat()
    },

    groups(state) {
      const determinations = getUnique(
        state.objects.map((o) => o.determination).filter((d) => d.otuId),
        'otuId'
      )

      return determinations.map((d, index) => ({
        determination: d,
        color: randomHue(index),
        list: state.objects.filter((o) => o.determination?.otuId === d.otuId)
      }))
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
      } catch (e) {
        throw e
      }

      this.isLoading = false
    }
  }
})
