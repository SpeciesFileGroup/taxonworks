import { TaxonNameRelationships } from 'routes/endpoints/TaxonNameRelationships'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, data) {
  const taxon_name_relationship = {
    object_taxon_name_id: state.taxon_name.id,
    subject_taxon_name_id: data.id,
    type: data.type
  }

  return new Promise((resolve, reject) => {
    TaxonNameRelationships.create({ taxon_name_relationship }).then(response => {
      commit(MutationNames.AddOriginalCombination, response.body)
      dispatch('loadSoftValidation', 'original_combination')
      resolve(response.body)
    }, response => {
      commit(MutationNames.SetHardValidation, response.body)
      reject(response.body)
    })
  })
}
