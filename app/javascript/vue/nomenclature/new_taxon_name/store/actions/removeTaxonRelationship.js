import { removeTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, relationship) {
  removeTaxonRelationship(relationship).then(response => {
    commit(MutationNames.RemoveTaxonRelationship, relationship)
    dispatch('loadSoftValidation', 'taxonRelationshipList')
    dispatch('loadSoftValidation', 'taxon_name')
  })
}
