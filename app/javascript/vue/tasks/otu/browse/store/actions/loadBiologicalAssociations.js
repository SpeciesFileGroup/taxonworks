import { GetBiologicalAssociations } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, globalId) => {
  return new Promise((resolve, reject) => {
    GetBiologicalAssociations(globalId).then(response => {
      commit(MutationNames.SetBiologicalAssociations, state.biologicalAssociations.concat(response.body))
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
