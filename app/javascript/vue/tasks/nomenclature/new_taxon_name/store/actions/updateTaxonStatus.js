import { updateTaxonStatus } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, status) {
  return new Promise((resolve, reject) => {
    const patchStatus = {
      taxon_name_classification: {
        id: status.id,
        taxon_name_id: state.taxon_name.id,
        type: status.type
      }
    }

    updateTaxonStatus(patchStatus).then(response => {
      Object.defineProperty(response.body, 'type', { value: status.type })
      Object.defineProperty(response.body, 'object_tag', { value: status.name })
      commit(MutationNames.AddTaxonStatus, response.body)
      dispatch('loadSoftValidation', 'taxon_name')
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxonStatusList')
      resolve(response.body)
    })
  })
}
