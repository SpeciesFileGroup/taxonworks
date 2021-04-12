import { MutationNames } from '../mutations/mutations'
import { GetExtract, GetSoftValidation } from '../../request/resources'

export default ({ commit }, id) => {
  GetExtract(id).then(({ body }) => {
    commit(MutationNames.SetExtract, body)

    GetSoftValidation(body.global_id).then(response => {
      commit(MutationNames.SetSoftValidation, response.body)
    })
  })
}
