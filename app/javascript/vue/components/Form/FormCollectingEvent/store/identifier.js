import { defineStore } from 'pinia'
import { Identifier, Namespace } from '@/routes/endpoints'
import { IDENTIFIER_LOCAL_TRIP_CODE } from '@/constants'

export default defineStore('tripCode', {
  state: () => ({
    namespace: undefined,
    identifier: {
      identifier: undefined,
      isUnsaved: false
    },
    increment: false
  }),

  getters: {
    isUnsaved(state) {
      return (
        state.identifier.isUnsaved &&
        this.namespace &&
        this.identifier.identifier
      )
    }
  },

  actions: {
    save({ objectId, objectType }) {
      const payload = {
        identifier: {
          id: this.identifier.id,
          identifier: this.identifier.identifier,
          namespace_id: this.namespace.id,
          identifier_object_id: objectId,
          identifier_object_type: objectType,
          type: IDENTIFIER_LOCAL_TRIP_CODE
        }
      }

      const request = this.identifier.id
        ? Identifier.update(this.identifier.id, payload)
        : Identifier.create(payload)

      request.then(({ body }) => {
        this.identifier = {
          id: body.id,
          identifier: body.identifier,
          isUnsaved: true
        }
      })

      return request
    },

    remove() {
      Identifier.destroy(this.identifier.id)

      this.$reset()
    },

    async load({ objectId, objectType }) {
      try {
        const { body } = Identifier.where({
          identifier_object_id: objectId,
          identifier_object_type: objectType,
          type: IDENTIFIER_LOCAL_TRIP_CODE
        })

        const [identifier] = body

        if (identifier) {
          this.identifier = {
            id: identifier.id,
            identifier: identifier.identifier,
            isUnsaved: false
          }

          Namespace.find(identifier.namespace_id).then(({ body }) => {
            this.namespace = body
          })
        }

        return body
      } catch (e) {}
    }
  }
})
