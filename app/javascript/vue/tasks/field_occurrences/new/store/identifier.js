import { IDENTIFIER_LOCAL_CATALOG_NUMBER } from '@/constants/index.js'
import { defineStore } from 'pinia'
import { Identifier, Namespace } from '@/routes/endpoints'
import makeIdentifier from '@/factory/Identifier.js'
import incrementIdentifier from '@/tasks/digitize/helpers/incrementIdentifier.js'

export default defineStore('identifiers', {
  state: () => ({
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
    async load({ objectId, objectType }) {
      return Identifier.where({
        identifier_object_id: objectId,
        identifier_object_type: objectType,
        type: IDENTIFIER_LOCAL_CATALOG_NUMBER
      }).then(async ({ body }) => {
        const [identifier] = body

        if (identifier) {
          this.namespace = (await Namespace.find(identifier.namespace_id)).body
          this.identifier = {
            ...identifier,
            isUnsaved: false
          }
        }
      })
    },

    reset({ keepNamespace }) {
      const newIdentifierId = this.increment
        ? incrementIdentifier(this.identifier.identifier)
        : null
      this.identifier = {
        ...makeIdentifier(),
        identifier: newIdentifierId,
      }

      if (!keepNamespace) {
        this.namespace = null
      }
    },

    save({ objectId, objectType }) {
      if (!this.identifier.isUnsaved ||
        !this.identifier.identifier || !this.namespace?.id
      ) {
        return
      }

      const payload = {
        identifier: {
          id: this.identifier.id,
          type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
          namespace_id: this.namespace.id,
          identifier: this.identifier.identifier,
          identifier_object_id: objectId,
          identifier_object_type: objectType
        }
      }

      const request = this.identifier.id
        ? Identifier.update(this.identifier.id, payload)
        : Identifier.create(payload)

      request
        .then(({ body }) => {
          this.identifier = body
        })
        .catch(() => {})

      return request
    }
  }
})
