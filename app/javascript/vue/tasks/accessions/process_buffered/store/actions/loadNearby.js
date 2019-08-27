import { GetNearbyCOFromDepictionSqedId } from '../../request/resource'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, id) => {
  GetNearbyCOFromDepictionSqedId(id).then(response => {
    commit(MutationNames.SetNearbyCO, response.body)
  })
}
