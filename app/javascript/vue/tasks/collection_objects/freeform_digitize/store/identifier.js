import { defineStore } from 'pinia'
import { IDENTIFIER_LOCAL_CATALOG_NUMBER, COLLECTION_OBJECT } from '@/constants'

export default defineStore('identifier', {
  state: () => ({
    id: undefined,
    namespace_id: undefined,
    identifier: undefined,
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER,
    identifier_object_type: COLLECTION_OBJECT,
    isUnsaved: true
  })
})
