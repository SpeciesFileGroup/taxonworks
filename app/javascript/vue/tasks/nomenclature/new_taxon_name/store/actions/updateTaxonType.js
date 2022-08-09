import { TaxonNameRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state, dispatch }, data) => {
  const taxon_name_relationship = {
    id: data.id,
    object_taxon_name_id: state.taxon_name.id,
    subject_taxon_name_id: state.taxonType.id,
    type: data.type
  }

  TaxonNameRelationship.update(taxon_name_relationship.id, { taxon_name_relationship }).then(response => {
    commit(MutationNames.AddTaxonRelationship, response.body)
    dispatch('loadSoftValidation', 'taxonRelationshipList')
    dispatch('loadSoftValidation', 'original_combination')
    dispatch('loadSoftValidation', 'taxon_name')
  }, response => {
    commit(MutationNames.SetHardValidation, response.body)
  })
  state.taxonType = undefined
}
