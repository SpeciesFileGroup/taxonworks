import { TaxonNameRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, dispatch }, relationship) =>
  TaxonNameRelationship.destroy(relationship.id).then(_ => {
    commit(MutationNames.RemoveTaxonRelationship, relationship)
    dispatch('loadSoftValidation', 'taxonRelationshipList')
    dispatch('loadSoftValidation', 'original_combination')
    dispatch('loadSoftValidation', 'taxonStatusList')
    dispatch('loadSoftValidation', 'taxon_name')
  })
