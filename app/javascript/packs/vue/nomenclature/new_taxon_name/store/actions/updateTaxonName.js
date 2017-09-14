const updateTaxonName = require('../../request/resources').updateTaxonName;
const MutationNames = require('../mutations/mutations').MutationNames;

module.exports = function({ commit, state, dispatch }, taxon) {
	commit(MutationNames.SetSaving, true);
	return new Promise(function(resolve, reject) {
		updateTaxonName(taxon).then( response => {
			if(!response.hasOwnProperty('taxon_name_author_roles')) {
				response['taxon_name_author_roles'] = [];
			}
		    response.roles_attributes = [];
			commit(MutationNames.SetTaxon, response);
			commit(MutationNames.SetHardValidation, undefined);
			dispatch('loadSoftValidation', 'taxon_name');
			commit(MutationNames.UpdateLastSave);
			commit(MutationNames.SetSaving, false);
			return resolve(response)
		}, response => {
			commit(MutationNames.SetHardValidation, response);
			commit(MutationNames.SetSaving, false);
			return reject(response);
		});
	});
};