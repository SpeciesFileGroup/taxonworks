import { createTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, data) {
  let relationship = {
    taxon_name_relationship: {
      object_taxon_name_id: state.taxonRelationship.id,
      subject_taxon_name_id: state.taxon_name.id,
      type: data.type
    }
  }
  commit(MutationNames.SetHardValidation, undefined)
  createTaxonRelationship(relationship).then(response => {
    commit(MutationNames.AddTaxonRelationship, response)
    dispatch('loadSoftValidation', 'taxon_name')
    dispatch('loadSoftValidation', 'taxonRelationshipList')
  }, response => {
    commit(MutationNames.SetHardValidation, response)
  })
  state.taxonRelationship = undefined
}
