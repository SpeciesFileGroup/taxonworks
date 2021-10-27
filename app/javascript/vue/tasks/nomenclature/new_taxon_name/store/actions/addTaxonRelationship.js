import { TaxonNameRelationship } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state, dispatch }, taxon_name_relationship) => 
  new Promise((resolve, reject) => {
    commit(MutationNames.SetHardValidation, undefined)
    TaxonNameRelationship.create({ taxon_name_relationship }).then(response => {
      commit(MutationNames.AddTaxonRelationship, response.body)
      dispatch('loadSoftValidation', 'taxon_name')
      dispatch('loadSoftValidation', 'taxonRelationshipList')
      dispatch('loadSoftValidation', 'taxonStatusList')
      dispatch('loadSoftValidation', 'original_combination')
      resolve(response.body)
    }, response => {
      commit(MutationNames.SetHardValidation, response.body)
      reject(response.body)
    })
    state.taxonRelationship = undefined
  })
