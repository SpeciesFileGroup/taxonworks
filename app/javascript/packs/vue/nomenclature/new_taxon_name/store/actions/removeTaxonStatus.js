const removeTaxonStatus = require('../../request/resources').removeTaxonStatus;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state, dispatch }, status) {
	removeTaxonStatus(status.id).then( response => {
		commit(MutationNames.RemoveTaxonStatus, status);
		dispatch('loadSoftValidation','taxonStatusList');
	});
};