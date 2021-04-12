import { DestroyExtract } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }, extract) => {
  const { recents } = state
  const index = recents.findIndex(item => item.id === extract.id)

  DestroyExtract(extract.id).then(() => {
    recents.splice(index, 1)
    commit(MutationNames.SetRecents, recents)
  })
}
