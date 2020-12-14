import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { GetTaxonNames } from '../../request/resources'

export default ({ dispatch, commit, state }, otus) => {
  function loadOtuInformation (otu) {
    const promises = []
    return new Promise((resolve, reject) => {
      promises.push(dispatch(ActionNames.LoadCollectionObjects, otu.id).then(() => {
        dispatch(ActionNames.LoadCollectingEvents, [otu.id])
      }))
      promises.push(dispatch(ActionNames.LoadBiologicalAssociations, otu.global_id))
      promises.push(dispatch(ActionNames.LoadDepictions, otu.id))
      promises.push(dispatch(ActionNames.LoadCommonNames, otu.id))

      Promise.all(promises).then(() => {
        resolve()
      })
    })
  }
  if (state.currentOtu.taxon_name_id) {
    dispatch(ActionNames.LoadTaxonName, state.currentOtu.taxon_name_id)
  }
  GetTaxonNames({ taxon_name_id: [...new Set(otus.map(otu => otu.taxon_name_id))] }).then(response => {
    commit(MutationNames.SetTaxonNames, response.body)
  })
  dispatch(ActionNames.LoadDescendants, state.currentOtu)
  dispatch(ActionNames.LoadAssertedDistributions, state.otus.map(otu => otu.id))
  dispatch(ActionNames.LoadPreferences)

  async function processArray(array) {
    for (const item of array) {
      await loadOtuInformation(item)
    }
    state.loadState.biologicalAssociations = false
    state.loadState.assertedDistribution = false
  }
  processArray(otus)
}
