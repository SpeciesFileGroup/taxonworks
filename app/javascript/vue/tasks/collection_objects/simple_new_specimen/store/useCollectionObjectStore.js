import { CollectionObject } from 'routes/endpoints'
import { defineStore } from 'pinia'
import { makeCollectionObject, makeCollectionObjectPayload } from 'adapters/index.js'

export const useCollectionObjectStore = defineStore('collectionObject', {
  state: () => ({
    collectionObject: makeCollectionObject({})
  }),

  actions: {
    async saveCollectionObject (params) {
      const payload = {
        collection_object: {
          ...makeCollectionObjectPayload(this.collectionObject),
          ...params
        }
      }

      const response = payload.id
        ? await CollectionObject.update(payload.id, payload)
        : await CollectionObject.create(payload)

      this.collectionObject = makeCollectionObject(response.body)

      return response
    }
  }
})
