import { MutationNames } from '../mutations/mutations'
import { CreateTaxonDetermination, UpdateTaxonDetermination } from '../../request/resources'
import ValidateDetermination from '../../validations/determination'

export default function ({ commit, state }) {
  return new Promise((resolve, reject) => {
    commit(MutationNames.SetTaxonDeterminationBiologicalId, state.collection_object.id)
    let taxon_determination = state.taxon_determination
    if(ValidateDetermination(taxon_determination)) {
      if(taxon_determination.id) {
        UpdateTaxonDetermination(taxon_determination).then(response => {
          TW.workbench.alert.create('Taxon determination was successfully updated.', 'notice')
          commit(MutationNames.SetTaxonDetermination, response)
          return resolve(response)
        })
      }
      else {
        CreateTaxonDetermination(taxon_determination).then(response => {
          TW.workbench.alert.create('Taxon determination was successfully created.', 'notice')
          commit(MutationNames.SetTaxonDetermination, response)
          return resolve(response)
        })
      }
    }
  })
}