import ActionNames from './actionNames'

export default ({ dispatch }, otus) => {
  otus.forEach(otu => {
    dispatch(ActionNames.LoadTaxonName, otu.taxon_name_id)
    dispatch(ActionNames.LoadCollectionObjects, otu.id).then(() => {
      dispatch(ActionNames.LoadCollectingEvents, [otu.id])
    })
    dispatch(ActionNames.LoadDescendants, otu)
    dispatch(ActionNames.LoadAssertedDistributions, otu.id)
  })
  dispatch(ActionNames.LoadPreferences)
}
