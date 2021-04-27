import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, id) {
  return new Promise(function (resolve, reject) {
    TaxonName.relationships(id, {
      as_subject: true,
      taxon_name_relationship_set: [
        'synonym',
        'status',
        'classification']
    }).then(response => {
      if (state.taxon_name.hasOwnProperty('type_taxon_name_relationship')) {
        response.body.push(state.taxon_name.type_taxon_name_relationship)
      }
      commit(MutationNames.SetTaxonRelationshipList, response.body)
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'original_combination')
      return resolve()
    })
  })
}
