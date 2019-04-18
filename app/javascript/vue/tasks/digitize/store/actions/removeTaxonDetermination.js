import { MutationNames } from '../mutations/mutations'
import { DestroyTaxonDetermination } from '../../request/resources'

export default function ({ commit, state }, determination) {
  return new Promise((resolve, reject) => {
    if(determination.hasOwnProperty('id')) {
      DestroyTaxonDetermination(determination.id).then(response => {
        commit(MutationNames.RemoveTaxonDetermination, determination.id)
      })
    }
    else {
      state.taxon_determinations.splice(
        state.taxon_determinations.findIndex(det => {
          return det.otu_id == determination.otu_id
        }), 1)
    }
  })
}