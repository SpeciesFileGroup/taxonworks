import { Project } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  Project.preferences().then(({ body }) => {
    commit(MutationNames.SetProjectPreferences, body)
  })
}
