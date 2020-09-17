import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'

export default ({ dispatch, commit }, otu) => {
  commit(MutationNames.SetCurrentOtu, otu)
  dispatch(ActionNames.LoadTaxonName, otu.taxon_name_id)
  dispatch(ActionNames.LoadCollectionObjects, otu.id).then(() => {
    dispatch(ActionNames.LoadCollectingEvents, [otu.id])
  })
  dispatch(ActionNames.LoadDescendants, otu)
  dispatch(ActionNames.LoadAssertedDistributions, otu.id)
  dispatch(ActionNames.LoadPreferences)
}
