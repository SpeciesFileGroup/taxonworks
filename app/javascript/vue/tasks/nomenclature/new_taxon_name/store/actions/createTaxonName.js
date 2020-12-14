import { createTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, taxon) {
  var taxon_name = {
    taxon_name: {
      name: taxon.name,
      parent_id: taxon.parent_id,
      rank_class: taxon.rank_string,
      type: 'Protonym'
    }
  }
  if(taxon.hasOwnProperty('taxon_name_classifications_attributes')) {
    taxon_name.taxon_name.taxon_name_classifications_attributes = taxon.taxon_name_classifications_attributes
  }
  return new Promise((resolve, reject) => {
    createTaxonName(taxon_name).then(response => {
      history.pushState(null, null, `/tasks/nomenclature/new_taxon_name?taxon_name_id=${response.body.id}`)
      TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully created.`, 'notice')
      commit(MutationNames.SetTaxon, response.body)
      commit(MutationNames.SetHardValidation, undefined)
      dispatch('loadSoftValidation', 'taxon_name')
      commit(MutationNames.UpdateLastSave)
      resolve(response.body)
    }, response => {
      commit(MutationNames.SetHardValidation, response.body)
      reject(response.body)
    })
  })
}
