import { GetUserPreferences } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  GetUserPreferences().then(response => {
    if (response.body.layout.browseOtu) {
      commit(MutationNames.SetPreferences, response.body.layout['browseOtu'])
    }
    state.userId = response.body.id
  })
}
