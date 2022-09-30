import { CollectionObject } from 'routes/endpoints'
import { makeCollectionObject } from 'adapters/index.js'

export default ({ state }, coId) => {
  CollectionObject.find(coId).then(({ body }) => {
    state.collectionObject = makeCollectionObject(body)
  })
}
