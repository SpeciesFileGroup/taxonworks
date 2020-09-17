import { updateTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, data) {
  let relationship = {
    taxon_name_relationship: {
      id: data.id,
      object_taxon_name_id: state.taxon_name.id,
      subject_taxon_name_id: state.taxonType.id,
      type: data.type
    }
  }
  updateTaxonRelationship(relationship).then(response => {
    commit(MutationNames.AddTaxonRelationship, response.body)
    dispatch('loadSoftValidation', 'taxonRelationshipList')
    dispatch('loadSoftValidation', 'original_combination')
    dispatch('loadSoftValidation', 'taxon_name')
  }, response => {
    commit(MutationNames.SetHardValidation, response.body)
  })
  state.taxonType = undefined
}
