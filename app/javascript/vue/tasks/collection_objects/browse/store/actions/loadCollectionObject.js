import {
  CollectionObject,
  Identifier,
  CollectingEvent,
  Georeference,
  Depiction
} from 'routes/endpoints'
import {
  makeCollectionObject,
  makeIdentifier
} from 'adapters/index.js'
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
    }
  })

  Identifier.where({
    identifier_object_id: coId,
    identifier_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    state.identifiers = body.map(item => makeIdentifier(item))
  })

  CollectionObject.depictions(coId).then(({ body }) => {
    state.depictions = body
  })
}
