import { MutationNames } from '../mutations/mutations'
import { GetUserPreferences } from '../../request/resources'

export default ({ state, commit }) => {
  GetUserPreferences().then(response => {
    commit(MutationNames.SetPreferences, response.body)
  })
}
