import { User } from '@/routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) =>
  User.preferences().then(({ body }) => {
    const browseOtuPreferences = body?.layout?.browseOtu

    if (browseOtuPreferences) {
      if (
        browseOtuPreferences.preferenceSchema ===
        state.preferences.preferenceSchema
      ) {
        commit(MutationNames.SetPreferences, browseOtuPreferences)
      }
    }
    state.userId = body.id
  })
