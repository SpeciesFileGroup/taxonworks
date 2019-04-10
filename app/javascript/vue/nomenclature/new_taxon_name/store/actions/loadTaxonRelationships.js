import { loadTaxonRelationships } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    loadTaxonRelationships(id).then(response => {
      commit(MutationNames.SetTaxonRelationshipList, response)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      return resolve()
    })
  })
}
