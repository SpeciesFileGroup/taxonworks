import SetParam from 'helpers/setParam.js'
import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import { Extract, SoftValidation } from 'routes/endpoints'

export default ({ commit, dispatch }, id) => {
  return Extract.find(id).then(({ body }) => {
    const promises = []
    SetParam(RouteNames.NewExtract, 'extract_id', id)
    body.roles_attributes = body.extractor_roles || []

    commit(MutationNames.SetExtract, body)
    promises.push(dispatch(ActionNames.LoadOriginRelationship, body))
    promises.push(dispatch(ActionNames.LoadProtocols, body))
    promises.push(dispatch(ActionNames.LoadIdentifiers, body))

    SoftValidation.find(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })

    Promise.all(promises).then(() => {
      commit(MutationNames.SetLastChange, 0)
    })
  })
}
