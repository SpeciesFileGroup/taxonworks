import { CollectionObject, Identifier } from 'routes/endpoints'
import { makeCollectionObject, makeIdentifier } from 'adapters/index.js'
import { COLLECTION_OBJECT } from 'constants/index.js'

export default async ({ state }, coId) => {
  state.collectionObject = makeCollectionObject((await CollectionObject.find(coId)).body)
  state.dwc = (await CollectionObject.find(coId)).body

  Identifier.where({
    identifier_object_id: coId,
    identifier_object_type: COLLECTION_OBJECT
  }).then(({ body }) => {
    state.identifiers = body.map(item => makeIdentifier(item))
  })
}
