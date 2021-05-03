import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state: { extract, identifiers } }) => {
  const promises = []
  const newIdentifiers = identifiers.filter(item => !item.id).map(identifier => ({ ...identifier, identifier_object_id: extract.id }))

  newIdentifiers.forEach(identifier => {
    promises.push(Identifier.create({ identifier }).then(({ body }) => {
      commit(MutationNames.AddIdentifier, body)
    }))
  })
}
