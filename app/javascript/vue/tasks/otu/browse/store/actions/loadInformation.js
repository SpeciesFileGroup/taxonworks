import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'

export default ({ dispatch, state, commit }, otu) => {
  commit(MutationNames.SetCurrentOtu, otu)
  dispatch(ActionNames.LoadCollectionObjects, otu.id)
  dispatch(ActionNames.LoadCollectingEvents, otu.id)
  dispatch(ActionNames.LoadAssertedDistributions, otu.id)
  dispatch(ActionNames.LoadPreferences)
}
