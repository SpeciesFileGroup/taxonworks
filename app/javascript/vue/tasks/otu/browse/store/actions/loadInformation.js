import ActionNames from './actionNames'

export default ({ dispatch, state }, otus) => {
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
  dispatch(ActionNames.LoadTaxonName, state.currentOtu.taxon_name_id)
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
