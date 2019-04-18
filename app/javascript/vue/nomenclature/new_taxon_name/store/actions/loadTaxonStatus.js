import { loadTaxonStatus } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    loadTaxonStatus(id).then(response => {
      commit(MutationNames.SetTaxonStatusList, response)
      dispatch('loadSoftValidation', 'taxonStatusList')
	    })
  })
}
