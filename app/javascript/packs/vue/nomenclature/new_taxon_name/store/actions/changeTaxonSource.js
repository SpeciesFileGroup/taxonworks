const changeTaxonSource = require('../../request/resources').changeTaxonSource;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state }, sourceId) {
	changeTaxonSource(state.taxon_name.id, sourceId, state.taxon_name.origin_citation).then( response => {
		commit(MutationNames.SetCitation, response);
	});
};