import { createTaxonRelationship } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, data) {
  let relationship = {
    taxon_name_relationship: {
      object_taxon_name_id: state.taxon_name.id,
      subject_taxon_name_id: data.id,
      type: data.type
    }
  }
  return new Promise((resolve, reject) => {
    createTaxonRelationship(relationship).then(response => {
      commit(MutationNames.AddOriginalCombination, response)
      resolve(response)
    }, response => {
      commit(MutationNames.SetHardValidation, response)
      reject(response)
    })
  })
}
