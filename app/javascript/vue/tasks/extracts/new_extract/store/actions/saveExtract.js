import { MutationNames } from '../mutations/mutations'
import { Extract, SoftValidation } from 'routes/endpoints'
import { RouteNames } from 'routes/routes'
import SetParam from 'helpers/setParam.js'
import { addToArray } from 'helpers/arrays'

export default ({ state: { extract, recents, repository, roles }, commit }) => {
  const payload = {
    ...extract,
    roles_attributes: roles,
    repository_id: repository?.id || null
  }

  return (extract.id
    ? Extract.update(extract.id, { extract: payload })
    : Extract.create({ extract: payload })
  ).then(({ body }) => {
    const roles = (body.extractor_roles || []).map(role =>
      ({
        ...role,
        person_id: role.person.id
      })
    )

    commit(MutationNames.SetRoles, roles)
    commit(MutationNames.SetExtract, body)
    addToArray(recents, body)
    SetParam(RouteNames.NewExtract, 'extract_id', body.id)

    SoftValidation.find(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })

    commit(MutationNames.SetLastSave, Date.now())
    return body
  })
}
