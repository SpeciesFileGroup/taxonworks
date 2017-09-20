const updateClassification = require('../../request/resources').updateClassification;
const MutationNames = require('../mutations/mutations').MutationNames;

module.exports = function({ dispatch, commit, state }, classification) {

	let patchClassification = {
		taxon_name_classification: classification
	}
	return new Promise(function(resolve, reject) {
		updateClassification(patchClassification).then( response => {
			commit(MutationNames.AddTaxonStatus, response);
			dispatch('loadSoftValidation', 'taxon_name');
			dispatch('loadSoftValidation', 'taxonStatusList');
			resolve(response);
		});
	});
};