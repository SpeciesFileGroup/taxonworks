import { MutationNames } from '../mutations/mutations'
import { CreateExtract, UpdateExtract } from '../../request/resources'

export default ({ state, commit }) => {
  const { extract, repository, identifiers } = state
  const saveExtract = extract.id ? UpdateExtract : CreateExtract

  extract.repository_id = repository?.id
  extract.identifiers_attributes = identifiers.filter(identifier => !identifier.id)

  return saveExtract(extract).then(({ body }) => {
    commit(MutationNames.SetExtract, body)
    return body
  })
}
