const updateClassification = require('../../request/resources').updateClassification;
const MutationNames = require('../mutations/mutations').MutationNames;

module.exports = function({ dispatch, commit, state }, status) {
	var position = state.taxonStatusList.findIndex( item => {
		if(item.type == status.type) {
			return true;
		}
	});
//	if (position < 0) {
		let patchClassification = {
			taxon_name_classification: status
		}
		console.log(patchClassification);
		updateClassification(patchClassification).then( response => {
			commit(MutationNames.AddTaxonStatus, response);
			dispatch('loadSoftValidation', 'taxon_name');
			dispatch('loadSoftValidation', 'taxonStatusList');
		});
//	}
};