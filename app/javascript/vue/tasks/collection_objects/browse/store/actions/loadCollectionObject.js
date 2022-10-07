import {
  CollectionObject,
  CollectingEvent,
  Georeference
} from 'routes/endpoints'
import { makeCollectionObject } from 'adapters/index.js'
import {
  COLLECTION_OBJECT,
  COLLECTING_EVENT
} from 'constants/index.js'
import ActionNames from './actionNames'

export default ({ state, dispatch }, coId) => {
  CollectionObject.find(coId).then(({ body }) => {
    const co = makeCollectionObject(body)

    state.collectionObject = co
    dispatch(ActionNames.LoadSoftValidation, {
      globalId: co.globalId,
      objectType: COLLECTION_OBJECT
    })
  })

  dispatch(ActionNames.LoadBiocurations, coId)

  CollectionObject.dwca(coId).then(({ body }) => {
    state.dwc = body
  })

  CollectionObject.timeline(coId).then(({ body }) => {
    state.timeline = body
  })

  CollectingEvent.where({ collection_object_id: [coId] }).then(({ body }) => {
    const ce = body[0]

    if (ce) {
      state.collectingEvent = ce

      Georeference.where({ collecting_event_id: ce.id }).then(({ body }) => {
        state.georeferences = body
      })

      dispatch(ActionNames.LoadSoftValidation, {
        globalId: ce.global_id,
        objectType: COLLECTING_EVENT
      })
      dispatch(ActionNames.LoadIdentifiersFor, {
        objectType: COLLECTING_EVENT,
        id: ce.id
      })
    }
  })

  dispatch(ActionNames.LoadIdentifiersFor, {
    objectType: COLLECTION_OBJECT,
    id: coId
  })

  CollectionObject.depictions(coId).then(({ body }) => {
    state.depictions = body
  })
}
