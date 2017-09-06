const saveTaxonStatus = require('../../request/resources').saveNewTaxonStatus;
const MutationNames = require('../mutations/mutations').MutationNames;

module.exports = function({ dispatch, commit, state }, status) {
	var position = state.taxonStatusList.findIndex( item => {
		if(item.type == status.type) {
			return true;
		}
	});
	if (position < 0) {
		let newClassification = {
			taxon_name_classification: {
				taxon_name_id: state.taxon_name.id,
				type: status.type
			}
		}
		saveTaxonStatus(newClassification).then( response => {
			Object.defineProperty(response, 'type', { value: status.type });
			Object.defineProperty(response, 'object_tag', { value: status.name });
			commit(MutationNames.AddTaxonStatus, response);
			dispatch('loadSoftValidation', 'taxon_name');
			dispatch('loadSoftValidation', 'taxonStatusList');
		});
	}

};