const removeTaxonRelationship = require('../../request/resources').removeTaxonRelationship;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state, dispatch }, relationship) {
	removeTaxonRelationship(relationship).then( response => {
		commit(MutationNames.RemoveTaxonRelationship, relationship);
		dispatch('loadSoftValidation', 'taxonRelationshipList');
		dispatch('loadSoftValidation', 'taxon_name');
	});
};