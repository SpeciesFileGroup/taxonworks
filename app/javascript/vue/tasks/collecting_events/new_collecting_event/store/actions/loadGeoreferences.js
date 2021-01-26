import { MutationNames } from '../mutations/mutations'
import { GetGeoreferences } from '../../request/resources'

export default ({ commit }, ceId) => {
  GetGeoreferences(ceId).then(response => {
    commit(MutationNames.SetGeoreferences, response.body)
  })
}
