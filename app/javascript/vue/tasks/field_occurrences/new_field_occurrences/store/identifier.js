import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from '@/constants/index.js'
import { defineStore } from 'pinia'
import { Identifier } from '@/routes/endpoints'
import makeIdentifier from '@/factory/Identifier.js'

export default defineStore('identifiers', {
  state: () => ({
    identifiers: [],
    identifier: makeIdentifier(),
    namespace: null,
    increment: false
  }),

  getters: {
    isUnsaved(state) {
      return (
        state.identifier.isUnsaved &&
        state.namespace &&
        state.identifier.identifier
      )
    }
  },

  actions: {
    load({ id, type }) {
      Identifier.where({
        identifier_object_id: id,
        identifier_object_type: type,
        type: IDENTIFIER_LOCAL_CATALOG_NUMBER
      }).then(({ body }) => {
        const [identifier] = body

        if (identifier) {
          this.identifier = {
            ...body,
            isUnsaved: false
          }
        }
      })
    },

    save({ objectId, objectType }) {
      if (!this.identifier.isUnsaved) return

      const payload = {
        identifier: {
          id: this.identifier.id,
          namespace_id: this.namespace.id,
          identifier: this.identifier.identifier,
          identifier_object_id: objectId,
          identifier_object_type: objectType
        }
      }

      const request = this.identifier.id
        ? Identifier.update(this.identifier, payload)
        : Identifier.create(payload)

      request
        .then(({ body }) => {
          this.identifier = body
        })
        .catch({})

      return request
    }
  }
})
