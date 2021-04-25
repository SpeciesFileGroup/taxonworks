import { TaxonNames } from 'routes/endpoints/TaxonNames'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    TaxonNames.classifications(id).then(response => {
      commit(MutationNames.SetTaxonStatusList, response.body)
      dispatch('loadSoftValidation', 'taxonStatusList')
    })
  })
}
