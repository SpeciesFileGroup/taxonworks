import { MutationNames } from '../mutations/mutations'
import ActionNames from './actionNames'
import { GetExtract, GetSoftValidation } from '../../request/resources'
import SetParam from 'helpers/setParam.js'
import { RouteNames } from 'routes/routes'

export default ({ commit, dispatch }, id) => {
  GetExtract(id).then(({ body }) => {
    SetParam(RouteNames.NewExtract, 'extract_id', id)
    commit(MutationNames.SetExtract, { ...body, roles_attributes: [] })

    dispatch(ActionNames.LoadOriginRelationship, body)
    dispatch(ActionNames.LoadProtocols, body)

    GetSoftValidation(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })
  })
}
