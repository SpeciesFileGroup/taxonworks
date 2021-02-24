import { removeTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, relationship) {
  return removeTaxonRelationship(relationship).then(response => {
    commit(MutationNames.RemoveTaxonRelationship, relationship)
    dispatch('loadSoftValidation', 'taxonRelationshipList')
    dispatch('loadSoftValidation', 'original_combination')
    dispatch('loadSoftValidation', 'taxonStatusList')
    dispatch('loadSoftValidation', 'taxon_name')
  })
}
