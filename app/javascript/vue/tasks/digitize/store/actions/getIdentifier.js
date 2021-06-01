import { Identifier } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  Identifier.find(id).then(response => {
    commit(MutationNames.SetIdentifier, response.body)
  })
}
