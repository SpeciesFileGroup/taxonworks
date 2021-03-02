import { GetUserPreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  GetUserPreferences().then(({ body }) => {
    commit(MutationNames.SetUserPreferences, body)
  })
}
