import { CollectionObject, CollectingEvent } from '@/routes/endpoints'
import { COLLECTING_EVENT, COLLECTION_OBJECT } from '@/constants'

export const QUERY_PARAMETER = {
  collecting_event_query: {
    model: COLLECTING_EVENT,
    service: CollectingEvent
  },

  collection_object_query: {
    model: COLLECTION_OBJECT,
    service: CollectionObject
  }
}
