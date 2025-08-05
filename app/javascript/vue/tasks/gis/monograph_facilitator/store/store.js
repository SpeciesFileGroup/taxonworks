import { defineStore } from 'pinia'
import { Georeference } from '@/routes/endpoints'
import { getUnique, randomHue, randomUUID } from '@/helpers'
import { makeMarkerStyle } from '../utils'
import { addToArray, removeFromArray } from '@/helpers'
import { toRaw } from 'vue'
import { QUERY_PARAMETER } from '@/tasks/data_attributes/field_synchronize/constants'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables'
import { sortGroupsByLastSelectedIndex } from '../utils/sortGroupsByLastSelectedIndex.js'
import { chunkArray } from '@/helpers'

const extend = ['taxon_determinations']
const MAX_RECORDS = 1000

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

    isObjectHover(state) {
      return (o) => {
        return state.hoverIds.includes(o.id)
      }
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

    sortedGroups(state) {
      const allSelected = []
      const someSelected = []
      const noneSelected = []

      state.groups.forEach((group) => {
        const length = group.list.length
        const count = group.list.filter((item) =>
          state.selectedIds.includes(item.id)
        ).length

        if (count === 0) {
          noneSelected.push(group)
        } else if (length !== count) {
          someSelected.push(group)
        } else {
          allSelected.push(group)
        }
      })

      return [
        ...sortGroupsByLastSelectedIndex(allSelected, state.selectedIds),
        ...sortGroupsByLastSelectedIndex(someSelected, state.selectedIds),
        ...sortGroupsByLastSelectedIndex(noneSelected, state.selectedIds)
      ]
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

      if (!queryParam.value) {
        TW.workbench.alert.create('Filter parameters are missing.', 'alert')
        return
      }

      const { service, model } = QUERY_PARAMETER[queryParam.value]
      const payload = {
        ...queryValue.value,
        per: MAX_RECORDS,
        extend
      }

      this.objectType = model
      this.isLoading = true

      try {
        const { body, headers } = await service.filter(payload)
        const totalRecords = Number(headers['pagination-total'])
        const ceIds = [
          ...new Set(body.map((c) => c.collecting_event_id).filter(Boolean))
        ]

        if (ceIds.length) {
          await this.loadGeoreferences(ceIds)
        }

        this.objects = body.map(makeObject)
        this.groups = buildGroups(this.objects)

        if (totalRecords > MAX_RECORDS) {
          TW.workbench.alert.create(
            `Result contains ${MAX_RECORDS} records, it may be truncated.`,
            'notice'
          )
        }
      } catch (e) {
        throw e
      }

      this.isLoading = false
    },

    async loadGeoreferences(ceIds) {
      const arrIds = chunkArray(ceIds, 50)
      const promises = arrIds.map((ids) =>
        Georeference.all({ collecting_event_id: ids })
      )

      const responses = await Promise.all(promises)
      const georeferences = responses.map((r) => r.body).flat()

      georeferences.forEach((g) => delete g.geo_json.properties.radius)

      this.georeferences = georeferences
    },

    setObjectVisibilityById(id, visible) {
      if (visible) {
        addToArray(this.hiddenIds, id, { primitive: true })
      } else {
        removeFromArray(this.hiddenIds, id, { primitive: true })
      }
    },

    setGroupVisibility(groupId, visible) {
      const group = this.groups.find((g) => g.uuid === groupId)
      const ids = group.list.map((o) => o.id)

      if (visible) {
        this.hiddenIds = [...new Set([this.hiddenIds, ids])].flat()
      } else {
        this.hiddenIds = this.hiddenIds.filter((id) => !ids.includes(id))
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
    },

    hideUnselected() {
      const ids = this.objectIds.filter((id) => !this.selectedIds.includes(id))

      this.hiddenIds = ids
    }
  }
})
