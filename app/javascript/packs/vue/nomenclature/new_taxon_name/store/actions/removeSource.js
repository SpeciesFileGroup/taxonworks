const removeTaxonSource = require('../../request/resources').removeTaxonSource;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state }, id) {
	removeTaxonSource(id).then( response => {
		commit(MutationNames.SetSource, undefined);
	});
};