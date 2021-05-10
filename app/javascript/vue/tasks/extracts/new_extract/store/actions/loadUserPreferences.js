import { User } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  User.preferences().then(({ body }) => {
    commit(MutationNames.SetUserPreferences, body)
  })
}
