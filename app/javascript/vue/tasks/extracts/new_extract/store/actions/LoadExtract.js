import SetParam from 'helpers/setParam.js'
import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { RouteNames } from 'routes/routes'
import { Extract, SoftValidation } from 'routes/endpoints'

export default ({ commit, dispatch }, id) => {
  Extract.find(id).then(({ body }) => {
    SetParam(RouteNames.NewExtract, 'extract_id', id)
    body.roles_attributes = body.extractor_roles || []
    commit(MutationNames.SetExtract, body)

    dispatch(ActionNames.LoadOriginRelationship, body)
    dispatch(ActionNames.LoadProtocols, body)
    dispatch(ActionNames.LoadIdentifiers, body)

    SoftValidation.find(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })
  })
}
