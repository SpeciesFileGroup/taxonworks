import { defineStore } from 'pinia'
import { OriginRelationship } from '@/routes/endpoints'
import { removeFromArray, addToArray, randomUUID } from '@/helpers'

export default defineStore('originRelationships', {
  state: () => ({
    originRelationships: []
  }),

  getters: {
    hasUnsaved(state) {
      return state.originRelationships.some((c) => c.isUnsaved || c._destroy)
    }
  },

  actions: {
    async load({ objectId, objectType }) {
      return OriginRelationship.where({
        old_object_id: objectId,
        old_object_type: objectType,
        per: 100
      }).then(({ body }) => {
        this.originRelationships = body.map((c) => ({
          ...c,
          uuid: randomUUID(),
          isUnsaved: false
        }))
      })
    },

    add(originRelationship) {
      addToArray(
        this.originRelationships,
        { ...originRelationship, isUnsaved: true },
        {
          property: 'uuid',
          prepend: true
        }
      )
    },

    remove(item) {
      if (item.id) {
        OriginRelationship.destroy(item.id)
          .then(() => {
            TW.workbench.alert.create(
              'Origin relationship was successfully deleted.',
              'notice'
            )
          })
          .catch({})
      }

      removeFromArray(this.originRelationships, item, { property: 'uuid' })
    },

    save({ objectId, objectType }) {
      const originRelationship = this.originRelationships.filter(
        (c) => c.isUnsaved
      )

      const requests = originRelationship.map((item) => {
        const payload = {
          origin_relationship: {
            old_object_id: objectId,
            old_object_type: objectType,
            new_object_id: item.objectiveId,
            new_object_type: item.objectiveType,
            position: item.position
          }
        }

        const request = item.id
          ? OriginRelationship.update(item.id, payload)
          : OriginRelationship.create(payload)

        request
          .then(({ body }) => {
            const data = Object.assign(body, {
              uuid: item.uuid,
              label: body.object_tag
            })

            addToArray(this.originRelationships, data, { property: 'uuid' })
          })
          .catch({})

        return request
      })

      return Promise.all(requests)
    }
  }
})
