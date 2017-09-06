const loadTaxonName = require('../../request/resources').loadTaxonName;
const loadTaxonStatus = require('../../request/resources').loadTaxonStatus;
const loadTaxonRelationships = require('../../request/resources').loadTaxonRelationships;
const MutationNames = require('../mutations/mutations').MutationNames;

const filterObject = require('../../helpers/filterObject');

module.exports = function({ commit, state, dispatch }, id) {
	return new Promise(function(resolve,reject) {
		loadTaxonName(id).then(response => {
			loadTaxonRelationships(response.id).then(response => {
				commit(MutationNames.SetTaxonRelationshipList, response);
				dispatch('loadSoftValidation', 'taxonRelationshipList');
			});
			loadTaxonStatus(response.id).then(response => {
				commit(MutationNames.SetTaxonStatusList, response);
				dispatch('loadSoftValidation', 'taxonStatusList');
	        });
			commit(MutationNames.SetNomenclaturalCode, response.nomenclatural_code);
			commit(MutationNames.SetTaxon, filterObject(response));
			dispatch('setParentAndRanks', response.parent);
			dispatch('loadSoftValidation', 'taxon_name');
			return resolve();
		})
	})
};