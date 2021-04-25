import { TaxonNameRelationships } from 'routes/endpoints/TaxonNameRelationships'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, relationship) {
  return new Promise((resolve, reject) => {
    TaxonNameRelationships.update(relationship.id, { taxon_name_relationship: relationship }).then(response => {
      commit(MutationNames.AddTaxonRelationship, response.body)
      dispatch('loadSoftValidation', 'taxon_name')
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxonStatusList')
      resolve(response)
    }, (error) => {
      reject(error)
    })
  })
}
