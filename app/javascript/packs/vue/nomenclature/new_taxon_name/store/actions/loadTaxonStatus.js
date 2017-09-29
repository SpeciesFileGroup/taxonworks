const loadTaxonStatus = require('../../request/resources').loadTaxonStatus;
const MutationNames = require('../mutations/mutations').MutationNames;

module.exports = function({ commit, state, dispatch }, id) {
	return new Promise(function(resolve,reject) {
		loadTaxonStatus(id).then(response => {
			commit(MutationNames.SetTaxonStatusList, response);
			dispatch('loadSoftValidation', 'taxonStatusList');
	    });
	});
};