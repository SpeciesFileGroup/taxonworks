import SetParam from 'helpers/setParam.js'
import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import { Extract, SoftValidation } from 'routes/endpoints'

export default ({ commit, dispatch }, id) =>
  Extract.find(id).then(({ body }) => {
    const roles = (body.extractor_roles || []).map(role =>
      ({
        ...role,
        person_id: role.person.id
      })
    )

    commit(MutationNames.SetRoles, roles)
    commit(MutationNames.SetExtract, body)

    const actions = [
      dispatch(ActionNames.LoadOriginRelationship, body),
      dispatch(ActionNames.LoadProtocols, body),
      dispatch(ActionNames.LoadIdentifiers, body)
    ]

    SetParam(RouteNames.NewExtract, 'extract_id', id)

    SoftValidation.find(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })

    Promise.all(actions).then(_ => {
      commit(MutationNames.SetLastChange, 0)
    })
  })
