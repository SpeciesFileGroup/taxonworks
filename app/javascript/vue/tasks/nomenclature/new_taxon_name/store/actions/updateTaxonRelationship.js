import { TaxonNameRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, dispatch }, taxon_name_relationship) =>
  new Promise((resolve, reject) => {
    TaxonNameRelationship.update(taxon_name_relationship.id, { taxon_name_relationship }).then(response => {
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
