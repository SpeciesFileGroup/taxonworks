import { updateClassification } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ dispatch, commit }, classification) {
  let patchClassification = {
    taxon_name_classification: classification
  }
  return new Promise(function (resolve, reject) {
    updateClassification(patchClassification).then(response => {
      commit(MutationNames.AddTaxonStatus, response.body)
      dispatch('loadSoftValidation', 'taxon_name')
      dispatch('loadSoftValidation', 'taxonStatusList')
      resolve(response.body)
    })
  })
}
