const removeTaxonRelationship = require('../../request/resources').removeTaxonRelationship;
const MutationNames = require('../mutations/mutations').MutationNames;  

module.exports = function({ commit, state }, relationship) {
	removeTaxonRelationship(relationship).then( response => {
		commit(MutationNames.RemoveTaxonRelationship, relationship);
	});
};