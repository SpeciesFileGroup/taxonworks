import { Identifier } from 'routes/endpoints'
import { COLLECTION_OBJECT, IDENTIFIER_LOCAL_CATALOG_NUMBER } from 'constants/index.js'

export default ({ state }, coId) => {
  Identifier.where({
    identifier_object_id: coId,
    identifier_object_type: COLLECTION_OBJECT,
    type: IDENTIFIER_LOCAL_CATALOG_NUMBER
  }).then(({ body }) => {
    state.identifiers = body
  })
}
