import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    TaxonName.classifications(id).then(response => {
      commit(MutationNames.SetTaxonStatusList, response.body)
      dispatch('loadSoftValidation', 'taxonStatusList')
    })
  })
}
