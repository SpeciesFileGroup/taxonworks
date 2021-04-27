import { TaxonNameRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, dispatch }, relationship) {
  return TaxonNameRelationship.destroy(relationship.id).then(response => {
    commit(MutationNames.RemoveTaxonRelationship, relationship)
    dispatch('loadSoftValidation', 'taxonRelationshipList')
    dispatch('loadSoftValidation', 'original_combination')
    dispatch('loadSoftValidation', 'taxonStatusList')
    dispatch('loadSoftValidation', 'taxon_name')
  })
}
