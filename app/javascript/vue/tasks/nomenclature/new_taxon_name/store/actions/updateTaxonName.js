import { MutationNames } from '../mutations/mutations'
import { TaxonName } from 'routes/endpoints'
import extend from '../../const/extendRequest.js'

export default ({ commit, state, dispatch }, taxon) => {
  commit(MutationNames.SetSaving, true)
  return new Promise((resolve, reject) => {
    const taxon_name = {
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
      type: 'Protonym',
    }

    if (taxon.hasOwnProperty('origin_citation_attributes')) {
      taxon_name.origin_citation_attributes = taxon.origin_citation_attributes
      delete state.taxon_name.origin_citation_attributes
    }

    TaxonName.update(taxon_name.id, { taxon_name, extend }).then(response => {
      TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully updated.`, 'notice')
      if (!response.body.hasOwnProperty('taxon_name_author_roles')) {
        response.body.taxon_name_author_roles = []
      }
      delete response.body.etymology
      response.body.roles_attributes = []
      commit(MutationNames.SetTaxon, response.body)
      commit(MutationNames.SetHardValidation, undefined)
      dispatch('loadSoftValidation', 'taxon_name')
      commit(MutationNames.UpdateLastSave)
      commit(MutationNames.SetSaving, false)
      return resolve(response.body)
    }, response => {
      commit(MutationNames.SetHardValidation, response.body)
      commit(MutationNames.SetSaving, false)
      return reject(response.body)
    })
  })
}
