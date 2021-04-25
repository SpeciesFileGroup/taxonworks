import { TaxonNameRelationships } from 'routes/endpoints/TaxonNameRelationships'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, dispatch }, relationship) {
  return TaxonNameRelationships.destroy(relationship.id).then(response => {
    commit(MutationNames.RemoveTaxonRelationship, relationship)
    dispatch('loadSoftValidation', 'taxonRelationshipList')
    dispatch('loadSoftValidation', 'original_combination')
    dispatch('loadSoftValidation', 'taxonStatusList')
    dispatch('loadSoftValidation', 'taxon_name')
  })
}
