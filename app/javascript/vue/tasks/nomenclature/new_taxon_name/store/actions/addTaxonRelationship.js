import { createTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, data) {
  return new Promise((resolve, reject) => {
    const relationship = {
      taxon_name_relationship: {
        object_taxon_name_id: data.taxonRelationshipId,
        subject_taxon_name_id: state.taxon_name.id,
        type: data.type
      }
    }
    commit(MutationNames.SetHardValidation, undefined)
    createTaxonRelationship(relationship).then(response => {
      commit(MutationNames.AddTaxonRelationship, response.body)
      dispatch('loadSoftValidation', 'taxon_name')
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'taxonStatusList')
      dispatch('loadSoftValidation', 'original_combination')
      resolve(response.body)
    }, response => {
      commit(MutationNames.SetHardValidation, response.body)
      reject(response.body)
    })
    state.taxonRelationship = undefined
  })
}
