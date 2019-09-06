import { updateTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, taxon) {
  commit(MutationNames.SetSaving, true)
  return new Promise(function (resolve, reject) {

      var taxon_name = {
        id: taxon.id,
        name: taxon.name,
        parent_id: taxon.parent_id,
        rank_class: taxon.rank_string,
        year_of_publication: taxon.year_of_publication,
        verbatim_author: taxon.verbatim_author,
        etymology: taxon.etymology,
        feminine_name: taxon.feminine_name,
        masculine_name: taxon.masculine_name,
        neuter_name: taxon.neuter_name,
        roles_attributes: taxon.roles_attributes,
        type: 'Protonym'
    }

    if(taxon.hasOwnProperty('origin_citation_attributes')) {
      taxon_name.origin_citation_attributes = taxon.origin_citation_attributes
      delete state.taxon_name.origin_citation_attributes
    }

    updateTaxonName(taxon_name).then(response => {
      if (!response.hasOwnProperty('taxon_name_author_roles')) {
        response['taxon_name_author_roles'] = []
      }
      response.roles_attributes = []
      commit(MutationNames.SetTaxon, response)
      commit(MutationNames.SetHardValidation, undefined)
      dispatch('loadSoftValidation', 'taxon_name')
      commit(MutationNames.UpdateLastSave)
      commit(MutationNames.SetSaving, false)
      return resolve(response)
    }, response => {
      commit(MutationNames.SetHardValidation, response)
      commit(MutationNames.SetSaving, false)
      return reject(response)
    })
  })
}
