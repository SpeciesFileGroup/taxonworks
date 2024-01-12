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

  actions: {
    loadIdentifier({ id, type }) {
      Identifier.where({
        identifier_object_id: id,
        identifier_object_type: type
      })
    }
  }
})
