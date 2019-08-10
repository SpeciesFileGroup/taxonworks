import { createTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, taxon) {
  createTaxonName(taxon).then(response => {
    history.pushState(null, null, `/tasks/nomenclature/new_taxon_name/${response.id}`)
    commit(MutationNames.SetTaxon, response)
    commit(MutationNames.SetHardValidation, undefined)
    dispatch('loadSoftValidation', 'taxon_name')
    commit(MutationNames.UpdateLastSave)
  }, response => {
    commit(MutationNames.SetHardValidation, response)
  })
}
