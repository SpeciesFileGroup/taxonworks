import { CreateIdentifier } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state }) => {
  const { extract, identifiers } = state
  const promises = []
  const newIdentifiers = identifiers.filter(item => !item.id).map(identifier => ({ ...identifier, identifier_object_id: extract.id }))

  newIdentifiers.forEach(item => {
    promises.push(CreateIdentifier(item).then(({ body }) => {
      commit(MutationNames.AddIdentifier, body)
    }))
  })
}
