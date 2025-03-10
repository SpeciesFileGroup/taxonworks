import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import { TaxonName } from '@/routes/endpoints'

export default async ({ dispatch, commit, state }, otus) => {
  const { currentOtu } = state
  const otuIds = otus.map((otu) => otu.id)
  const taxonNameIds = [
    ...new Set(otus.map((otu) => otu.taxon_name_id))
  ].filter(Boolean)

  await dispatch(ActionNames.LoadPreferences)

  async function loadOtuInformation(otu) {
    await Promise.all([
      dispatch(ActionNames.LoadBiologicalAssociations, otu.global_id),
      dispatch(ActionNames.LoadDepictions, otu.id),
      dispatch(ActionNames.LoadCommonNames, otu.id)
    ])
  }

  if (currentOtu.taxon_name_id) {
    await dispatch(ActionNames.LoadTaxonName, currentOtu.taxon_name_id)
  }

  dispatch(ActionNames.LoadDistribution, currentOtu.id)

  if (taxonNameIds.length) {
    TaxonName.all({
      taxon_name_id: taxonNameIds
    }).then((response) => {
      commit(MutationNames.SetTaxonNames, response.body)
    })
  }

  dispatch(ActionNames.LoadObservationDepictions, otus)
  dispatch(ActionNames.LoadDescendants, state.currentOtu)

  async function processArray(otus) {
    for (const item of otus) {
      await loadOtuInformation(item)
    }

    dispatch(ActionNames.LoadCollectionObjects, otuIds).then(() => {
      dispatch(ActionNames.LoadCollectingEvents, otuIds)
    })
    dispatch(ActionNames.LoadFieldOccurrences, otuIds)

    state.loadState.biologicalAssociations = false
    state.loadState.assertedDistribution = false
  }
  processArray(otus)
  dispatch(
    ActionNames.LoadAssertedDistributions,
    state.otus.map((otu) => otu.id)
  )
}
