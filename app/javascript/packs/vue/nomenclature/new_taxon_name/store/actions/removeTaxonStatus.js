const removeTaxonStatus = require('../../request/resources').removeTaxonStatus;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state, dispatch }, status) {
	return new Promise((resolve, reject) => {
		removeTaxonStatus(status.id).then( response => {
			commit(MutationNames.RemoveTaxonStatus, status);
			dispatch('loadSoftValidation', 'taxonStatusList');
			dispatch('loadSoftValidation', 'taxon_name');
			resolve(response);
		});
	});
};