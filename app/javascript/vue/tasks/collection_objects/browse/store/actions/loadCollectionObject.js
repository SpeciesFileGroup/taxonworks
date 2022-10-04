import { CollectionObject, Identifier, CollectingEvent, Georeference } from 'routes/endpoints'
import { makeCollectionObject, makeIdentifier } from 'adapters/index.js'
import { COLLECTION_OBJECT } from 'constants/index.js'

export default ({ state }, coId) => {
  CollectionObject.find(coId).then(({ body }) => {
    state.collectionObject = makeCollectionObject(body)
  })

  CollectionObject.dwca(coId).then(({ body }) => {
    state.dwc = body
  })

  CollectingEvent.where({ collection_object_id: [coId] }).then(({ body }) => {
    const ce = body[0]
    if (ce) {
      state.collectingEvent = ce

      Georeference.where({ collecting_event_id: ce.id }).then(({ body }) => {
        state.georeferences = body
      })
    }
  })

  Identifier.where({
    identifier_object_id: coId,
    identifier_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    state.identifiers = body.map(item => makeIdentifier(item))
  })
}
