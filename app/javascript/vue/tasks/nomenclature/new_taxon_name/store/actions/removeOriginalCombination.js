import { removeTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, combination) {
  return new Promise((resolve, reject) => {
    removeTaxonRelationship(combination).then(response => {
      commit(MutationNames.RemoveOriginalCombination, combination)
      commit(MutationNames.RemoveTaxonRelationship, combination)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxon_name')
      resolve(response.body)
    })
  })
}
