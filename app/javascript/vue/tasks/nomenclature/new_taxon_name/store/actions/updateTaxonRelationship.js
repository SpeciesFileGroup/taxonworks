import { updateTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, relationship) {
  return new Promise((resolve, reject) => {
    let patchRelationship = {
      taxon_name_relationship: relationship
    }
    updateTaxonRelationship(patchRelationship).then(response => {
      commit(MutationNames.AddTaxonRelationship, response.body)
      dispatch('loadSoftValidation', 'taxon_name')
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxonStatusList')
      resolve(response)
    }, (error) => {
      reject(error)
    })
  })
}
