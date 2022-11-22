import { defineStore } from 'pinia'
import {
  CollectionObject,
  CollectingEvent,
  Identifier
} from 'routes/endpoints'
import { IDENTIFIER_LOCAL_CATALOG_NUMBER, COLLECTION_OBJECT } from 'constants/index'

const makeInitialState = () => ({
  settings: {
    lock: {
      collectingEvent: false,
      determination: false,
      identifier: false,
      namespace: false,
      preparationType: false
    },
    increment: false
  },
  createdIdentifiers: [],
  collectionObject: {
    preparation_type_id: undefined
  },
  collectingEvent: {
    verbatim_label: undefined,
    verbatim_locality: undefined,
    geographic_area_id: undefined
  },
  geographicArea: undefined,
  identifier: {
    identifier: undefined,
    identifier_object_id: undefined,
    identifier_object_type: COLLECTION_OBJECT,
    namespace_id: undefined,
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER
  },
  otu: undefined
})

export const useStore = defineStore('main', {
  state: makeInitialState,

  actions: {
    async createNewSpecimen () {
      const payload = {
        collection_object: {
          ...this.collectionObject
        }
      }

      const response = payload.id
        ? await CollectionObject.update(payload.id, payload)
        : await CollectionObject.create(payload)

      return response
    },

    getIdentifiers () {
      if (!this.identifier.identifier) {
        this.createdIdentifiers = []
        return
      }

      Identifier.where({
        type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
        namespace_id: this.identifier.namespace_id,
        identifier: this.identifier.identifier
      }).then(({ body }) => {
        this.createdIdentifiers = body
      })
    }
  }
})
