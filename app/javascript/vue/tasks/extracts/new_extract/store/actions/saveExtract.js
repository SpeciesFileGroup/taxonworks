import { MutationNames } from '../mutations/mutations'
import { CreateExtract, UpdateExtract, GetSoftValidation } from '../../request/resources'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'

export default ({ state, commit }) => {
  const { extract, repository, identifiers, protocols } = state
  const saveExtract = extract.id ? UpdateExtract : CreateExtract

  extract.repository_id = repository?.id
  extract.identifiers_attributes = identifiers.filter(identifier => !identifier.id)
  extract.protocol_relationships_attributes = protocols.map(item => ({ protocol_id: item.id }))

  return saveExtract(extract).then(({ body }) => {
    SetParam(RouteNames.NewExtract, 'extract_id', body.id)
    commit(MutationNames.SetExtract, body)
    GetSoftValidation(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })
    return body
  })
}
