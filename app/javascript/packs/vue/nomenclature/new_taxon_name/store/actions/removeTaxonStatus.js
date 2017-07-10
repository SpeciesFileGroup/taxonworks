const removeTaxonStatus = require('../../request/resources').removeTaxonStatus;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state }, status) {
	removeTaxonStatus(status.id).then( response => {
		commit(MutationNames.RemoveTaxonStatus, status);
	});
};