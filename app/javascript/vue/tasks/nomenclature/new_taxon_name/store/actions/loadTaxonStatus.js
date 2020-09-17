import { loadTaxonStatus } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    loadTaxonStatus(id).then(response => {
      commit(MutationNames.SetTaxonStatusList, response.body)
      dispatch('loadSoftValidation', 'taxonStatusList')
    })
  })
}
