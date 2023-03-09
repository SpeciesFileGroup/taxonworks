import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { TaxonName } from 'routes/endpoints'

export default ({ dispatch, commit, state }, otus) => {
  const otuIds = otus.map((otu) => otu.id)

  function loadOtuInformation(otu) {
    const promises = []
    return new Promise((resolve, reject) => {
      promises.push(
        dispatch(ActionNames.LoadBiologicalAssociations, otu.global_id)
      )
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
  TaxonName.all({
    taxon_name_id: [...new Set(otus.map((otu) => otu.taxon_name_id))]
  }).then((response) => {
    commit(MutationNames.SetTaxonNames, response.body)
  })

  dispatch(ActionNames.LoadObservationDepictions, otus)
  dispatch(ActionNames.LoadDescendants, state.currentOtu)
  dispatch(ActionNames.LoadPreferences)

  async function processArray(otus) {
    for (const item of otus) {
      await loadOtuInformation(item)
    }

    dispatch(ActionNames.LoadCollectionObjects, otuIds).then(() => {
      dispatch(ActionNames.LoadCollectingEvents, otuIds)
    })

    state.loadState.biologicalAssociations = false
    state.loadState.assertedDistribution = false
  }
  processArray(otus)
  dispatch(
    ActionNames.LoadAssertedDistributions,
    state.otus.map((otu) => otu.id)
  )
}
