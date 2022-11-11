import { Identifier } from 'routes/endpoints'
import { defineStore } from 'pinia'

export const useCollectingEventStore = defineStore('collectingEvent', {
  state: () => ({
    identifier: {
      id: undefined,
      namespace_id: undefined,
      type: undefined,
      identifier: undefined,
      identifier_object_type: undefined,
      identifier_object_id: undefined
    }
  }),

  actions: {
    async saveIdentifier (params) {
      const payload = {
        identifier: {
          ...this.identifier,
          ...params
        }
      }

      const response = payload.id
        ? await Identifier.update(payload.id, payload)
        : await Identifier.create(payload)

      this.identifier = response.body
    }
  }
})
