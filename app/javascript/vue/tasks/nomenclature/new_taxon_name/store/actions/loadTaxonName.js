import { TaxonNames } from 'routes/endpoints/TaxonNames'
import { MutationNames } from '../mutations/mutations'

import filterObject from '../../helpers/filterObject'

export default function ({ commit, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    TaxonNames.find(id).then(response => {
      if (response.body.hasOwnProperty('parent')) {
        commit(MutationNames.SetNomenclaturalCode, response.body.nomenclatural_code)
        commit(MutationNames.SetTaxon, filterObject(response.body))
        dispatch('setParentAndRanks', response.body.parent)
        dispatch('loadSoftValidation', 'taxon_name')
        resolve(response.body)
      } else {
        if (response.body.name === 'Root') {
          TW.workbench.alert.create('Root can not be edited', 'error')
        }
        reject(response.body)
      }
    }, (response) => {
      TW.workbench.alert.create('There is no taxon name associated to that ID', 'error')
      reject(response.body)
    })
  })
}
