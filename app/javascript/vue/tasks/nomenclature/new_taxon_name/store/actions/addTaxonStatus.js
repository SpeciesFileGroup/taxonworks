import { TaxonNameClassification } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ dispatch, commit, state }, status) => {
  const position = state.taxonStatusList.findIndex(item => item.type === status.type)

  if (position < 0) {
    const newClassification = {
      taxon_name_classification: {
        taxon_name_id: state.taxon_name.id,
        type: status.type
      }
    }
    return new Promise(function (resolve, reject) {
      TaxonNameClassification.create(newClassification).then(response => {
        Object.defineProperty(response.body, 'type', { value: status.type })
        Object.defineProperty(response.body, 'object_tag', { value: status.name })
        commit(MutationNames.AddTaxonStatus, response.body)
        dispatch('loadSoftValidation', 'taxon_name')
        dispatch('loadSoftValidation', 'taxonStatusList')
        dispatch('loadSoftValidation', 'taxonRelationshipList')
        dispatch('loadSoftValidation', 'original_combination')
        return resolve(response.body)
      }, response => {
        return reject(response.body)
      })
    })
  }
}
