import { GetProjectPreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  GetProjectPreferences().then(({ body }) => {
    commit(MutationNames.SetProjectPreferences, body)
  })
}
