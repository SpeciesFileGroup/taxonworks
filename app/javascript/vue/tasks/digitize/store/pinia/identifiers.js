import { defineStore } from 'pinia'
import { Identifier } from '@/routes/endpoints'
import incrementIdentifier from '../../helpers/incrementIdentifier'

export function useIdentifierStore(type) {
  function makeIdentifier(obj) {
    return {
      id: obj.id,
      identifier: obj.identifier,
      namespaceId: obj.namespace_id,
      objectId: obj.identifier_object_id,
      objectType: obj.identifier_object_type,
      type,
      isUnsaved: false
    }
  }

  function makePayload(obj) {
    return {
      identifier: {
        id: obj.id,
        identifier: obj.identifier,
        namespace_id: obj.namespaceId,
        identifier_object_id: obj.objectId,
        identifier_object_type: obj.objectType,
        type
      }
    }
  }

  return defineStore(`identifier-${type}`, {
    state: () => ({
      identifier: {
        id: null,
        identifier: null,
        namespaceId: null,
        type,
        isUnsaved: true
      },
      namespace: null,
      identifiers: [],
      existingIdentifiers: []
    }),

    getters: {
      isNamespaceSet(state) {
        return (
          state.identifier.namespaceId && state.identifier.identifier?.length
        )
      }
    },

    actions: {
      checkExistingIdentifiers() {
        Identifier.where({
          namespace_id: this.identifier.namespaceId,
          identifier: this.identifier.identifier,
          type
        }).then(({ body }) => {
          this.existingIdentifiers = body.filter(
            (item) => item.id !== this.identifier.id
          )
        })
      },

      save({ objectId, objectType, forceUpdate }) {
        const isUnsaved = forceUpdate || this.identifier.isUnsaved
        const isIdentifierValid =
          !this.existingIdentifiers.length &&
          this.identifier.identifier &&
          this.identifier.namespaceId

        if (!isIdentifierValid) return
        if (!isUnsaved) return

        const payload = makePayload({
          ...this.identifier,
          objectId,
          objectType
        })

        const request = this.identifier.id
          ? Identifier.update(this.identifier.id, payload)
          : Identifier.create(payload)

        request
          .then(({ body }) => {
            this.identifier = makeIdentifier(body)
          })
          .catch(() => {})

        return request
      },

      load({ objectId, objectType }) {
        const request = Identifier.where({
          identifier_object_type: objectType,
          identifier_object_id: objectId,
          type
        })
          .then(({ body }) => {
            const list = body.map(makeIdentifier)

            this.identifiers = list

            if (list.length) {
              this.identifier = list[0]
            }
          })
          .catch(() => {})

        return request
      },

      reset({ keepNamespace, increment }) {
        const { namespaceId, identifier } = this.identifier

        this.$reset()

        if (keepNamespace) {
          this.identifier.namespaceId = namespaceId
        }

        if (increment) {
          this.identifier.identifier = incrementIdentifier(identifier)
        }
      }
    }
  })
}
