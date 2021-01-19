import { GetSoftValidation } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, globalId) => {
  GetSoftValidation(globalId).then(response => {
    commit(MutationNames.SetSoftValidations, response.body.validations.soft_validations)
  })
}
