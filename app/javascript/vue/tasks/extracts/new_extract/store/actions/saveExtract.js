import { MutationNames } from '../mutations/mutations'
import { CreateExtract, UpdateExtract, GetSoftValidation } from '../../request/resources'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'

export default ({ state, commit }) => {
  const { extract, repository } = state
  const saveExtract = extract.id ? UpdateExtract : CreateExtract

  extract.repository_id = repository?.id || null

  return saveExtract(extract).then(({ body }) => {
    body.roles_attributes = body.extractor_roles || []

    SetParam(RouteNames.NewExtract, 'extract_id', body.id)
    commit(MutationNames.SetExtract, body)
    GetSoftValidation(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })
    return body
  })
}
