import { updateTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, relationship) {
  let patchRelationship = {
    taxon_name_relationship: relationship
  }
  updateTaxonRelationship(patchRelationship).then(response => {
    commit(MutationNames.AddTaxonRelationship, response)
    dispatch('loadSoftValidation', 'taxon_name')
    dispatch('loadSoftValidation', 'taxonRelationshipList')
  })
}
