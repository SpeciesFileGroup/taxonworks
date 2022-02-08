import { MutationNames } from '../mutations/mutations'
import { Extract, SoftValidation } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'
import { addToArray } from 'helpers/arrays'

export default ({ state: { extract, recents, repository }, commit }) => {
  extract.repository_id = repository?.id || null

  return (extract.id
    ? Extract.update(extract.id, { extract })
    : Extract.create({ extract })
  ).then(({ body }) => {
    body.roles_attributes = body.extractor_roles || []

    addToArray(recents, body)
    SetParam(RouteNames.NewExtract, 'extract_id', body.id)
    commit(MutationNames.SetExtract, body)

    SoftValidation.find(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })

    commit(MutationNames.SetLastSave, Date.now())
    return body
  })
}
