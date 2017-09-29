const createTaxonName = require('../../request/resources').createTaxonName;
const MutationNames = require('../mutations/mutations').MutationNames;

module.exports = function({ commit, state, dispatch }, taxon) {
	createTaxonName(taxon).then( response => {
		commit(MutationNames.SetTaxon, response);
		commit(MutationNames.SetHardValidation, undefined);
		dispatch('loadSoftValidation', 'taxon_name');
		commit(MutationNames.UpdateLastSave);
	}, response => {
		commit(MutationNames.SetHardValidation, response);
	});
};