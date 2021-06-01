import { MutationNames } from '../mutations/mutations'
import { TaxonNameClassification } from 'routes/endpoints'

export default function ({ dispatch, commit }, taxon_name_classification) {
  return new Promise(function (resolve, reject) {
    TaxonNameClassification.update(taxon_name_classification.id, { taxon_name_classification }).then(response => {
      commit(MutationNames.AddTaxonStatus, response.body)
      dispatch('loadSoftValidation', 'taxon_name')
      dispatch('loadSoftValidation', 'taxonStatusList')
      resolve(response.body)
    })
  })
}
