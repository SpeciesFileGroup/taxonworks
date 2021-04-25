import { TaxonNameRelationships } from 'routes/endpoints/TaxonNameRelationships'
import { removeTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, dispatch }, combination) {
  return new Promise((resolve, reject) => {
    TaxonNameRelationships.destroy(combination.id).then(response => {
      commit(MutationNames.RemoveOriginalCombination, combination)
      commit(MutationNames.RemoveTaxonRelationship, combination)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxon_name')
      resolve(response.body)
    })
  })
}
