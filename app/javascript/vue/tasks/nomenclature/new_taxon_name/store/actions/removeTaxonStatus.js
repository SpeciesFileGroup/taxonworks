import { removeTaxonStatus } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, status) {
  return new Promise((resolve, reject) => {
    removeTaxonStatus(status.id).then(response => {
      commit(MutationNames.RemoveTaxonStatus, status)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxonStatusList')
      dispatch('loadSoftValidation', 'taxon_name')
      resolve(response.body)
    })
  })
}
