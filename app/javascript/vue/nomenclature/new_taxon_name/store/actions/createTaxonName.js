import { createTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, taxon) {
  createTaxonName(taxon).then(response => {
    commit(MutationNames.SetTaxon, response)
    commit(MutationNames.SetHardValidation, undefined)
    dispatch('loadSoftValidation', 'taxon_name')
    commit(MutationNames.UpdateLastSave)
  }, response => {
    commit(MutationNames.SetHardValidation, response)
  })
}
