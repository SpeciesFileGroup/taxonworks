const removeTaxonRelationship = require('../../request/resources').removeTaxonRelationship;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state, dispatch }, combination) {
	 return new Promise((resolve, reject) => {
		removeTaxonRelationship(combination).then( response => {
			commit(MutationNames.RemoveOriginalCombination, combination);
			dispatch('loadSoftValidation', 'taxonRelationshipList');
			dispatch('loadSoftValidation', 'taxon_name');
			resolve(response);
		});
	});
};