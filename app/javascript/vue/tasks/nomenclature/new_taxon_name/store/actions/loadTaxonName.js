import { loadTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

import filterObject from '../../helpers/filterObject'

export default function ({ commit, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    loadTaxonName(id).then(response => {
      if(response.hasOwnProperty('parent')) {
        commit(MutationNames.SetNomenclaturalCode, response.nomenclatural_code)
        commit(MutationNames.SetTaxon, filterObject(response))
        dispatch('setParentAndRanks', response.parent)
        dispatch('loadSoftValidation', 'taxon_name')
        resolve(response)
      }
      else {
        reject(response)
      }
    }, (response) => {
      reject(response)
    })
  })
}
