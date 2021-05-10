import { Extract } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, extract) => {
  const { recents } = state
  const index = recents.findIndex(item => item.id === extract.id)

  Extract.destroy(extract.id).then(() => {
    recents.splice(index, 1)
    commit(MutationNames.SetRecents, recents)
  })
}
