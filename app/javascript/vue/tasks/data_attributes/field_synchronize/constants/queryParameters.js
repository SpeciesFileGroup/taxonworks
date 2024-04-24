import { CollectionObject, CollectingEvent } from '@/routes/endpoints'
import { COLLECTING_EVENT, COLLECTION_OBJECT } from '@/constants'
import { RouteNames } from '@/routes/routes'

export const QUERY_PARAMETER = {
  collecting_event_query: {
    model: COLLECTING_EVENT,
    service: CollectingEvent,
    filterUrl: RouteNames.FilterCollectingEvents
  },

  collection_object_query: {
    model: COLLECTION_OBJECT,
    service: CollectionObject,
    filterUrl: RouteNames.FilterCollectionObjects
  }
}
