import { Identifier } from 'routes/endpoints'
import { makeIdentifier } from 'adapters'

export default ({ state }, { objectType, id }) => {
  Identifier.where({
    identifier_object_id: id,
    identifier_object_type: objectType
  }).then(({ body }) => {
    state.identifiers[objectType] = body.map(item => makeIdentifier(item))
  })
}
