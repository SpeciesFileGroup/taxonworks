import { MutationNames } from '../mutations/mutations'
import { GetExtract, GetSoftValidation } from '../../request/resources'
import SetParam from 'helpers/setParam.js'
import { RouteNames } from 'routes/routes'

export default ({ commit }, id) => {
  GetExtract(id).then(({ body }) => {
    SetParam(RouteNames.NewExtract, 'extract_id', id)
    commit(MutationNames.SetExtract, body)

    GetSoftValidation(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })
  })
}
