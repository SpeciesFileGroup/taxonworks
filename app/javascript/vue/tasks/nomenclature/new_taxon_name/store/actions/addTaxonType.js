import { TaxonNameRelationships } from 'routes/endpoints/TaxonNameRelationships'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, data) {
  return new Promise((resolve, reject) => {
    const taxon_name_relationship = {
      object_taxon_name_id: state.taxon_name.id,
      subject_taxon_name_id: state.taxonType.id,
      type: data.type
    }
    TaxonNameRelationships.create({ taxon_name_relationship }).then(response => {
      commit(MutationNames.AddTaxonRelationship, response.body)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      dispatch('loadSoftValidation', 'taxon_name')
      resolve(response)
    }, response => {
      commit(MutationNames.SetHardValidation, response.body)
      reject(response)
    })
    state.taxonType = undefined
  })
}
