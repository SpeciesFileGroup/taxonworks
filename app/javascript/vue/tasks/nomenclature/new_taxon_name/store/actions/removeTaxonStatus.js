import { TaxonNameClassification } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, status) {
  return new Promise((resolve, reject) => {
    TaxonNameClassification.destroy(status.id).then(response => {
      commit(MutationNames.RemoveTaxonStatus, status)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxonStatusList')
      dispatch('loadSoftValidation', 'taxon_name')
      resolve(response.body)
    })
  })
}
